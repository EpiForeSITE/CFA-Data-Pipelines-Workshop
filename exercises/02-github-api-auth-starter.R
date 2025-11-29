# GitHub API Authentication Exercise - Starter Code
# CFA Data Pipelines Workshop - Week 2
#
# Instructions:
# 1. Generate a GitHub personal access token
#    - Go to: https://github.com/settings/tokens
#    - Click "Generate new token (classic)"
#    - Select scopes: repo, read:user
#    - Copy the token (starts with ghp_)
#
# 2. Set it as an environment variable in .Renviron:
#    GITHUB_TOKEN=ghp_your_token_here
#
# 3. Complete the TODOs below

library(httr2)

# TODO: Load your GitHub token from environment variable
token <- ___________

# TODO: Create a request to the GitHub API user repos endpoint
# Endpoint: https://api.github.com/user/repos
response <- request(___________) |>
  # TODO: Add authentication using req_auth_bearer_token()
  ___________ |>
  req_perform()

# TODO: Check the response status
resp_check_status(response)

# TODO: Extract the JSON data from the response
repos <- ___________

# TODO: Print the total number of repositories
cat(sprintf("Total repositories: %d\n", ___________))

# TODO: Loop through the first 5 repos and print name and star count
for (repo in ___________) {
  cat(sprintf("%s: %d stars\n", 
              ___________, 
              ___________))
}

# BONUS 1: Filter for public repos only
# Hint: Use the 'private' field (FALSE means public)
public_repos <- ___________

cat(sprintf("\nPublic repositories: %d\n", ___________))

# BONUS 2: Get the latest commit for each of your first 3 repos
# Hint: Use endpoint https://api.github.com/repos/{owner}/{repo}/commits
# and add ?per_page=1 to get just the latest
for (repo in ___________) {
  commit_response <- request(___________) |>
    req_url_query(per_page = 1) |>
    req_auth_bearer_token(token) |>
    req_perform()
  
  commits <- resp_body_json(commit_response)
  
  if (length(commits) > 0) {
    cat(sprintf("%s - Latest commit: %s\n",
                ___________,
                ___________))
  }
}
