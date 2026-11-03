# store-infra — Azure Terraform example

Companion code for **Deploying Terraform to Azure with GitHub Actions and OIDC**. Visit the [Turing Technology Services blog](https://blog.turingts.com/).

The workflow files in this nested sample directory are inert in the public companion repository. Read the [repository README](../README.md) before copying the sample into your own separately configured private repository. Run the commands below from this `store-infra` directory. Local mock validation does not demonstrate a live Azure deployment.

## Layout

- `bootstrap/`: one-time administrator-owned foundation. Copy its Terraform files and lock into a separate secured local directory for each subscription. Never reuse foundation state across subscriptions.
- `terraform/`: Service Bus namespace and queue. Environment inputs and Blob backend configuration live under `vars/`.
- `.github/workflows/`: private trusted same-repository PR plan, then main -> Dev -> Stage -> Production. Pre-create GitHub environments and configure their reviewers/branch policies before use.

## Before execution

Use existing subscriptions and an existing common Entra tenant (the tutorial's proposed default), administrator-approved Azure CLI access for bootstrap, and globally unique state storage/namespace names. The administrator preregisters Microsoft.Storage, Microsoft.ManagedIdentity and Microsoft.ServiceBus. Replace every placeholder; the example values do not identify provisioned resources.

Create AZURE_CLIENT_ID, AZURE_TENANT_ID and AZURE_SUBSCRIPTION_ID as GitHub environment secrets from that environment's bootstrap outputs, under Settings → Environments → Environment secrets. Check the exact GitHub immutable repository/environment subject. Stage and Production must require approval before both plan and apply; Dev has no reviewer gate. Required environment reviewers for a private repository need an eligible GitHub plan.

Workload Contributor is scoped to the dedicated workload resource group; state Blob Data Contributor is scoped separately to its container. The same deployment-capable identity is used by plan and apply. No client secret, account key or SAS token is used.

## Local checks (no cloud provisioning)

The committed locks contain linux_amd64 and darwin_arm64 checksums. Add your platform with `terraform providers lock -platform=OS_ARCH` if necessary. From a clean local validation context without cloud credentials:

```bash
terraform -chdir=bootstrap init -lockfile=readonly
terraform -chdir=bootstrap validate
terraform -chdir=bootstrap test
terraform -chdir=terraform init -backend=false -lockfile=readonly
terraform -chdir=terraform validate
terraform -chdir=terraform test
```

Every test file uses `mock_provider "azurerm"`. Bootstrap tests are kept in separate files so each subscription fixture gets independent mock state; their mocked apply operations do not create Azure resources. The workflow uses the real backend, not backend-disabled init.

Before any real administrator setup or promotion, review the repository prerequisites and configure your own private repository. Review saved plans before applying. Do not run untrusted PR code with these identities, automatically apply stale plans, or put state/plans in Git.
