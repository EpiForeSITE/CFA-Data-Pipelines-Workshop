# GitHub API Authentication Exercise - Solution
# CFA Data Pipelines Workshop - Week 2

library(httr2)

# Load your GitHub token from environment variable
token <- Sys.getenv("GITHUB_TOKEN")

# Verify token is loaded
if (token == "") {
  stop("GITHUB_TOKEN not found. Please set it in your .Renviron file.")
}

# Create a request to the GitHub API user repos endpoint
response <- request("https://api.github.com/user/repos") |>
  req_auth_bearer_token(token) |>
  req_perform()

# Check the response status
resp_check_status(response)

# Extract the JSON data from the response
repos <- resp_body_json(response)

# Print the total number of repositories
cat(sprintf("Total repositories: %d\n", length(repos)))

# Loop through the first 5 repos and print name and star count
cat("\nFirst 5 repositories:\n")
for (repo in repos[1:min(5, length(repos))]) {
  cat(sprintf("%s: %d stars\n", 
              repo$name, 
              repo$stargazers_count))
}

# BONUS 1: Filter for public repos only
public_repos <- Filter(function(repo) !repo$private, repos)

cat(sprintf("\nPublic repositories: %d\n", length(public_repos)))
cat("Public repos:\n")
for (repo in public_repos[1:min(5, length(public_repos))]) {
  cat(sprintf("  - %s: %d stars\n", repo$name, repo$stargazers_count))
}

# BONUS 2: Get the latest commit for each of your first 3 repos
cat("\nLatest commits for first 3 repos:\n")
for (repo in repos[1:min(3, length(repos))]) {
  # Get user login (owner of the repo)
  owner <- repo$owner$login
  repo_name <- repo$name
  
  commit_url <- sprintf("https://api.github.com/repos/%s/%s/commits", 
                        owner, repo_name)
  
  commit_response <- request(commit_url) |>
    req_url_query(per_page = 1) |>
    req_auth_bearer_token(token) |>
    req_perform()
  
  commits <- resp_body_json(commit_response)
  
  if (length(commits) > 0) {
    commit_msg <- commits[[1]]$commit$message
    # Get first line of commit message
    commit_msg <- strsplit(commit_msg, "\n")[[1]][1]
    
    cat(sprintf("%s - Latest commit: %s\n",
                repo_name,
                commit_msg))
  } else {
    cat(sprintf("%s - No commits found\n", repo_name))
  }
}
