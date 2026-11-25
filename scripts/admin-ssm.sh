#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 NOM_ASG [REGION]" >&2
  exit 2
fi

asg_name="$1"
aws_region="${2:-us-east-1}"
export AWS_PAGER=""

instance_list=$(aws autoscaling describe-auto-scaling-groups \
  --region "$aws_region" \
  --auto-scaling-group-names "$asg_name" \
  --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`].InstanceId' \
  --output text)

if [[ -z "$instance_list" || "$instance_list" == "None" ]]; then
  echo "Aucune instance en service dans cet ASG : $asg_name" >&2
  exit 1
fi

read -r -a instance_ids <<< "$instance_list"
printf "ASG : %s — Instances : %s\n" "$asg_name" "${instance_ids[*]}"

command_id=$(aws ssm send-command \
  --region "$aws_region" \
  --document-name "AWS-RunShellScript" \
  --instance-ids "${instance_ids[@]}" \
  --comment "Pizza del ESGI : verification et rechargement nginx" \
  --parameters '{"commands":["set -eu","nginx -t","systemctl reload nginx","systemctl is-active nginx"]}' \
  --timeout-seconds 60 \
  --query 'Command.CommandId' \
  --output text)

printf "Commande SSM : %s\n" "$command_id"
result=0

for instance_id in "${instance_ids[@]}"; do
  printf "\nInstance : %s\n" "$instance_id"
  if ! aws ssm wait command-executed \
    --region "$aws_region" \
    --command-id "$command_id" \
    --instance-id "$instance_id"; then
    result=1
  fi

  if ! aws ssm get-command-invocation \
    --region "$aws_region" \
    --command-id "$command_id" \
    --instance-id "$instance_id" \
    --query '{Instance:InstanceId,Statut:Status,Sortie:StandardOutputContent,Erreur:StandardErrorContent}' \
    --output json; then
    result=1
  fi
done

exit "$result"
