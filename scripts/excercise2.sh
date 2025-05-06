
# step 1: prepare env vars -  replace with Your Github organization and repo!
githubOrganizationName='mygithubuser'
githubRepositoryName='toy-website-workflow'

# step2: create app registration
applicationRegistrationDetails=$(az ad app create --display-name 'toy-website-workflow')
applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')

# step3: configure federated GitHub credentials
az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-workflow\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

   resourceGroupResourceId=$(az group create --name ToyWebsite --location eastus --query id --output tsv)

# step4: create service principal & RBAC assignment
az ad sp create --id $applicationRegistrationObjectId
az role assignment create \
   --assignee $applicationRegistrationAppId \
   --role Contributor \
   --scope $resourceGroupResourceId

# step5: export secrets
echo "AZURE_CLIENT_ID: $applicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"
