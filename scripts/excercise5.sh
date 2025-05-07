
# step 1: prepare env vars -  replace with Your Github organization and repo!
githubOrganizationName='pawelsiwek'
githubRepositoryName='global-azure-2025-gdn'

# step2: create app registrations for test and prod
testApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-workflow-test')
testApplicationRegistrationObjectId=$(echo $testApplicationRegistrationDetails | jq -r '.id')
testApplicationRegistrationAppId=$(echo $testApplicationRegistrationDetails | jq -r '.appId')

prodApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-workflow-prod')
prodApplicationRegistrationObjectId=$(echo $prodApplicationRegistrationDetails | jq -r '.id')
prodApplicationRegistrationAppId=$(echo $prodApplicationRegistrationDetails | jq -r '.appId')

# step3: configure federated GitHub credentials for test and prod
az ad app federated-credential create \
   --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments-test1\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Test\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments-test-branch1\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


az ad app federated-credential create \
   --id $prodApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments-production1\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Production\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $prodApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments-production-branch1\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

#step4: create test and prod resource groups
testResourceGroupResourceId=$(az group create --name ToyWebsiteTest --location eastus --query id --output tsv)

az ad sp create --id $testApplicationRegistrationObjectId
az role assignment create \
   --assignee $testApplicationRegistrationAppId \
   --role Contributor \
   --scope $testResourceGroupResourceId

prodResourceGroupResourceId=$(az group create --name ToyWebsiteProduction --location eastus --query id --output tsv)

az ad sp create --id $prodApplicationRegistrationObjectId
az role assignment create \
   --assignee $prodApplicationRegistrationAppId \
   --role Contributor \
   --scope $prodResourceGroupResourceId


 # step5: export secrets
  echo "AZURE_CLIENT_ID_TEST: $testApplicationRegistrationAppId"
  echo "AZURE_CLIENT_ID_PRODUCTION: $prodApplicationRegistrationAppId"
  echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
  echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"

#step6: cleanup
az group delete --resource-group ToyWebsite --yes --no-wait
