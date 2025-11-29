# Workshop Exercises

This directory contains hands-on exercises for the CFA Data Pipelines Workshop.

## Exercise 2: GitHub API Authentication

**Objective:** Learn to authenticate with APIs using personal access tokens and fetch data from the GitHub API.

### Files:
- `02-github-api-auth-starter.R` - R starter code with TODOs
- `02-github-api-auth-solution.R` - Complete R solution
- `02-github-api-auth-starter.py` - Python starter code with TODOs
- `02-github-api-auth-solution.py` - Complete Python solution

### Prerequisites:
1. Generate a GitHub personal access token:
   - Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
   - Click "Generate new token (classic)"
   - Give it a descriptive note (e.g., "Workshop API Demo")
   - Select scopes: `repo`, `read:user`
   - Generate and copy the token (starts with `ghp_`)

2. Set the token as an environment variable:

   **For R (.Renviron file):**
   ```
   GITHUB_TOKEN=ghp_your_token_here
   ```
   Restart R after editing `.Renviron`

   **For Python:**
   ```bash
   # macOS/Linux
   export GITHUB_TOKEN=ghp_your_token_here
   
   # Windows PowerShell
   $env:GITHUB_TOKEN = "ghp_your_token_here"
   ```

### Tasks:
1. Fetch your repositories using the GitHub API
2. Print repository names and star counts
3. **Bonus:** Filter for public repositories only
4. **Bonus:** Get the latest commit for each repository

### Learning Goals:
- Understand personal access token authentication
- Make authenticated API requests
- Parse JSON responses
- Handle pagination and filtering

## Security Note
⚠️ Never commit your personal access token to version control! Always use environment variables or secure credential stores.
