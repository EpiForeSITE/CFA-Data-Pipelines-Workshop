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
# 2. Set it as an environment variable:
#    export GITHUB_TOKEN=ghp_your_token_here  # macOS/Linux
#    $env:GITHUB_TOKEN = "ghp_your_token_here"  # Windows PowerShell
#
# 3. Complete the TODOs below

import requests
import os

# TODO: Load your GitHub token from environment variable
token = ___________

# TODO: Create headers dict with Authorization
headers = {___________}

# TODO: Make GET request to GitHub API user repos endpoint
# Endpoint: https://api.github.com/user/repos
response = requests.get(___________, headers=___________)

# TODO: Check if request was successful (status code 200)
if response.status_code == ___________:
    # TODO: Parse JSON response
    repos = ___________
    
    # TODO: Print total number of repositories
    print(f"Total repositories: {___________}")
    
    # TODO: Loop through first 5 repos and print name and star count
    for repo in ___________:
        print(f"{___________}: {___________} stars")
else:
    print(f"Error: {response.status_code}")
    print(response.text)

# BONUS 1: Filter for public repos only
# Hint: Check the 'private' field (False means public)
public_repos = ___________

print(f"\nPublic repositories: {___________}")

# BONUS 2: Get the latest commit for each of your first 3 repos
# Hint: Use endpoint https://api.github.com/repos/{owner}/{repo}/commits
# and add params={'per_page': 1} to get just the latest
print("\nLatest commits for first 3 repos:")
for repo in ___________:
    owner = ___________
    repo_name = ___________
    
    commit_url = f"https://api.github.com/repos/{___________}/{___________}/commits"
    commit_response = requests.get(
        commit_url,
        headers=headers,
        params={'per_page': 1}
    )
    
    if commit_response.status_code == 200:
        commits = commit_response.json()
        if commits:
            commit_msg = ___________
            print(f"{repo_name} - Latest commit: {commit_msg}")
