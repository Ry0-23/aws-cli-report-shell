
#!/bin/bash
#######################
# Author  : Harsh
# Date    : 9th April
# Version : v2
#
# This script reports AWS resource usage across
# S3, EC2, Lambda, and IAM with formatted output.
#######################

set -euo pipefail

# ─────────────────────────────────────────────
# Colors & Formatting
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}========================================${RESET}"
    echo -e "${CYAN}${BOLD}  $1${RESET}"
    echo -e "${CYAN}${BOLD}========================================${RESET}"
}

print_success() { echo -e "${GREEN}✔  $1${RESET}"; }
print_warning() { echo -e "${YELLOW}⚠  $1${RESET}"; }
print_error()   { echo -e "${RED}✘  $1${RESET}"; }

check_aws_cli() {
    if ! command -v aws &>/dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
}

check_aws_auth() {
    if ! aws sts get-caller-identity &>/dev/null; then
        print_error "AWS credentials not configured or invalid. Run 'aws configure'."
        exit 1
    fi
}

# ─────────────────────────────────────────────
# Resource Functions
# ─────────────────────────────────────────────
list_s3_buckets() {
    print_header "S3 Buckets"
    local output
    output=$(aws s3 ls 2>&1)
    if [ -z "$output" ]; then
        print_warning "No S3 buckets found."
    else
        local count
        count=$(echo "$output" | wc -l | tr -d ' ')
        print_success "Total buckets: $count"
        echo "$output"
    fi
}

list_ec2_instances() {
    print_header "EC2 Instances"
    local output
    output=$(aws ec2 describe-instances \
        --query 'Reservations[].Instances[].[InstanceId, InstanceType, State.Name, PublicIpAddress, Tags[?Key==`Name`].Value | [0]]' \
        --output table 2>&1)
    if echo "$output" | grep -q "None\|no instances"; then
        print_warning "No EC2 instances found."
    else
        print_success "EC2 instances listed below:"
        echo "$output"
    fi
}

list_lambda_functions() {
    print_header "Lambda Functions"
    local output
    output=$(aws lambda list-functions \
        --query 'Functions[].[FunctionName, Runtime, MemorySize, Timeout, LastModified]' \
        --output table 2>&1)
    if [ -z "$output" ] || echo "$output" | grep -q "None"; then
        print_warning "No Lambda functions found."
    else
        print_success "Lambda functions listed below:"
        echo "$output"
    fi
}

list_iam_users() {
    print_header "IAM Users"
    local output
    output=$(aws iam list-users \
        --query 'Users[].[UserName, UserId, CreateDate, PasswordLastUsed]' \
        --output table 2>&1)
    if [ -z "$output" ] || echo "$output" | grep -q "None"; then
        print_warning "No IAM users found."
    else
        local count
        count=$(aws iam list-users --query 'length(Users)' --output text)
        print_success "Total IAM users: $count"
        echo "$output"
    fi
}

# ─────────────────────────────────────────────
# Optional: show current AWS identity
# ─────────────────────────────────────────────
show_identity() {
    print_header "AWS Identity"
    aws sts get-caller-identity --output table
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
main() {
    echo -e "${BOLD}"
    echo "  ╔══════════════════════════════════════╗"
    echo "  ║       AWS Resource Usage Report      ║"
    echo "  ║         $(date '+%Y-%m-%d  %H:%M:%S')         ║"
    echo "  ╚══════════════════════════════════════╝"
    echo -e "${RESET}"

    check_aws_cli
    check_aws_auth
    show_identity

    list_s3_buckets
    list_ec2_instances
    list_lambda_functions
    list_iam_users

    echo ""
    echo -e "${GREEN}${BOLD}✔  Report complete.${RESET}"
    echo ""
}

main "$@"

