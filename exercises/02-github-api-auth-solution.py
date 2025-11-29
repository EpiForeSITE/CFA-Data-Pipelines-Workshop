# GitHub API Authentication Exercise - Solution
# CFA Data Pipelines Workshop - Week 2

import requests
import os

# Load your GitHub token from environment variable
token = os.getenv('GITHUB_TOKEN')

# Verify token is loaded
if not token:
    raise ValueError("GITHUB_TOKEN not found. Please set it as an environment variable.")

# Create headers dict with Authorization
headers = {'Authorization': f'token {token}'}

# Make GET request to GitHub API user repos endpoint
response = requests.get('https://api.github.com/user/repos', headers=headers)

# Check if request was successful
if response.status_code == 200:
    # Parse JSON response
    repos = response.json()
    
    # Print total number of repositories
    print(f"Total repositories: {len(repos)}")
    
    # Loop through first 5 repos and print name and star count
    print("\nFirst 5 repositories:")
    for repo in repos[:5]:
        print(f"{repo['name']}: {repo['stargazers_count']} stars")
else:
    print(f"Error: {response.status_code}")
    print(response.text)
    exit(1)

# BONUS 1: Filter for public repos only
public_repos = [repo for repo in repos if not repo['private']]

print(f"\nPublic repositories: {len(public_repos)}")
print("Public repos:")
for repo in public_repos[:5]:
    print(f"  - {repo['name']}: {repo['stargazers_count']} stars")

# BONUS 2: Get the latest commit for each of your first 3 repos
print("\nLatest commits for first 3 repos:")
for repo in repos[:3]:
    owner = repo['owner']['login']
    repo_name = repo['name']
    
    commit_url = f"https://api.github.com/repos/{owner}/{repo_name}/commits"
    commit_response = requests.get(
        commit_url,
        headers=headers,
        params={'per_page': 1}
    )
    
    if commit_response.status_code == 200:
        commits = commit_response.json()
        if commits:
            # Get first line of commit message
            commit_msg = commits[0]['commit']['message'].split('\n')[0]
            print(f"{repo_name} - Latest commit: {commit_msg}")
    else:
        print(f"{repo_name} - No commits found")
