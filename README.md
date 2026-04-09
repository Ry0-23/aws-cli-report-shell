# AWS Resource Usage Reporter

A lightweight Bash script that gives you a clean, color-coded CLI report of your key AWS resources — S3, EC2, Lambda, and IAM — in one command.

---

## Author

| Field   | Details        |
|---------|----------------|
| Author  | Harsh          |
| Date    | 9th April 2025 |
| Version | v2             |

---

## Features

- ✅ **S3** — Lists all buckets with total count
- ✅ **EC2** — Shows Instance ID, type, state, public IP, and Name tag in a table
- ✅ **Lambda** — Displays function name, runtime, memory, timeout, and last modified
- ✅ **IAM** — Lists users with creation date and last password used
- ✅ **Identity check** — Shows the active AWS account/role before running
- ✅ **Pre-flight checks** — Validates AWS CLI installation and credentials before doing anything
- ✅ **Color-coded output** — Green for success, yellow for warnings, red for errors
- ✅ **Safe scripting** — Uses `set -euo pipefail` to catch errors, unset variables, and pipe failures

---

## Prerequisites

- **AWS CLI v2** installed → [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **AWS credentials configured** with sufficient permissions (see [Permissions](#permissions) below)
- **Bash 4+** (standard on Linux; use `brew install bash` on macOS if needed)

---

## Installation

```bash
# Clone or download the script
git clone https://github.com/your-username/aws-resource-reporter.git
cd aws-resource-reporter

# Make it executable
chmod +x aws_resource_report.sh
```

---

## Usage

```bash
./aws_resource_report.sh
```

### Example Output

```
  ╔══════════════════════════════════════╗
  ║       AWS Resource Usage Report      ║
  ║         2025-04-09  14:32:01         ║
  ╚══════════════════════════════════════╝

========================================
  AWS Identity
========================================
...

========================================
  S3 Buckets
========================================
✔  Total buckets: 3
2024-01-10 09:15:22 my-app-bucket
2024-03-22 11:45:00 logs-bucket
2025-01-01 00:00:00 backup-bucket

========================================
  EC2 Instances
========================================
✔  EC2 instances listed below:
----------------------------------------------------------
| i-0abc123  | t2.micro  | running | 3.95.12.4 | WebServer |
----------------------------------------------------------

...

✔  Report complete.
```

---

## Permissions

The IAM user or role running this script needs the following minimum permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": "s3:ListAllMyBuckets",     "Resource": "*" },
    { "Effect": "Allow", "Action": "ec2:DescribeInstances",    "Resource": "*" },
    { "Effect": "Allow", "Action": "lambda:ListFunctions",     "Resource": "*" },
    { "Effect": "Allow", "Action": "iam:ListUsers",            "Resource": "*" },
    { "Effect": "Allow", "Action": "sts:GetCallerIdentity",    "Resource": "*" }
  ]
}
```

---

## Project Structure

```
aws-resource-reporter/
├── aws_resource_report.sh   # Main script
└── README.md                # This file
```

---

## What Changed from v1 → v2

| Area | v1 | v2 |
|------|----|----|
| Error handling | `set -x` (debug trace only) | `set -euo pipefail` (safe mode) |
| Credential check | None | `sts get-caller-identity` pre-flight |
| CLI check | None | Validates `aws` command exists |
| EC2 output | Raw JSON dump | Formatted table with key columns |
| Lambda output | Raw JSON dump | Formatted table with key columns |
| IAM output | Raw JSON dump | Formatted table with key columns |
| Empty results | Silent | Warning message shown |
| Colors | None | Green / Yellow / Red output |
| Identity info | Not shown | Shown at the start of every run |

---

## License

MIT — free to use, modify, and distribute.
