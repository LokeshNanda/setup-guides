# Github SSH for Multiple Client or Personal Projects 

This setup ensures that the correct authentication (SSH key) and commit author information (`user.name` and `user.email`) are used automatically for each project.

## Step 1: Generate Separate SSH Keys

You need a unique SSH key pair (private and public key) for each GitHub account. Open **Git Bash** or **Windows Terminal** (PowerShell/CMD may also work, but Git Bash is standard for Git commands).

1.  **Generate the Personal Key:** (If you already have a key named `id_rsa`, you can skip this, or name your *new* key for work as `id_rsa_work`).
    ```bash
    ssh-keygen -t rsa -b 4096 -C "your_personal_email@example.com" -f ~/.ssh/id_rsa_personal
    ```
2.  **Generate the Work Key:**
    ```bash
    ssh-keygen -t rsa -b 4096 -C "your_work_email@company.com" -f ~/.ssh/id_rsa_work
    ```
      * When prompted for a **passphrase**, you can enter one for extra security or press **Enter** twice for no passphrase.
      * The private keys (`id_rsa_personal`, `id_rsa_work`) will be saved in your user's `.ssh` directory (`C:\Users\YOUR_USERNAME\.ssh`).


## Step 2: Add Public Keys to GitHub

You need to copy the contents of the public key files (`.pub` files) and add them to the corresponding GitHub accounts.

1.  **Copy the Public Key Content:**
      * For your personal key:
        ```bash
        cat ~/.ssh/id_rsa_personal.pub
        ```
      * For your work key:
        ```bash
        cat ~/.ssh/id_rsa_work.pub
        ```
      * Copy the entire output (starting with `ssh-rsa` or `ssh-ed25519`).
2.  **Add to GitHub:**
      * Log into your **Personal GitHub Account** $\rightarrow$ **Settings** $\rightarrow$ **SSH and GPG keys** $\rightarrow$ **New SSH key**. Paste the content of `id_rsa_personal.pub` and give it a descriptive title (e.g., "Windows Personal Laptop").
      * Log into your **Work GitHub Account** $\rightarrow$ **Settings** $\rightarrow$ **SSH and GPG keys** $\rightarrow$ **New SSH key**. Paste the content of `id_rsa_work.pub` and give it a title (e.g., "Windows Work Laptop").

## Step 3: Configure the SSH Client

Create or edit the SSH configuration file (`~/.ssh/config`) to tell Git/SSH which key to use based on the repository host.

1.  **Open/Create `~/.ssh/config`:** You can do this in VS Code or any text editor.
    ```bash
    # In Git Bash
    code ~/.ssh/config 
    # Or in Windows Explorer: Navigate to C:\Users\YOUR_USERNAME\.ssh and create a file named 'config' (with no extension).
    ```
2.  **Add Configuration:** Add the following entries, using distinct `Host` nicknames (e.g., `github-personal` and `github-work`):
    ```ini
    # Personal GitHub Account
    Host github-personal
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_rsa_personal
      IdentitiesOnly yes

    # Work GitHub Account
    Host github-work
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_rsa_work
      IdentitiesOnly yes
    ```

## Step 4: Configure Git User Info (Per Project)

This step ensures your commits show the correct name and email in VS Code for each repository, overriding the global settings.

1.  **Set Global Default (Optional but Recommended):** Set your most-used account (e.g., Personal) as the global default.

    ```bash
    git config --global user.name "Your Personal Name"
    git config --global user.email "your_personal_email@example.com"

    Ex:
    git config --global user.name "LokeshNanda"
    git config --global user.email "lokesh.nanda91@gmail.com"
    ```

2.  **Set Local (Project-Specific) Override:** For your work projects, navigate into the project folder in your terminal and set the *local* configuration. This overrides the global settings for *only* that repository.

    ```bash
    # Navigate to your work project folder
    cd /path/to/my/work/project

    # Set the name and email for THIS project only (no --global flag)
    git config user.name "Your Work Name"
    git config user.email "your_work_email@company.com"
    ```

    Repeat this for any project that needs an identity different from the global setting.

## Step 5: Update Repository Remote URLs

For the SSH configuration to work, you must change your local repository's remote URL to use the **Host nickname** you created in Step 3.

  * **Original Clone URL (for example):** `git@github.com:personal-user/repo.git`

  * **Change the Remote URL (in your project directory):**

      * **For Personal Projects:**
        ```bash
        cd /path/to/personal/project
        git remote set-url origin git@github-personal:personal-user/repo.git

        Example:
        git remote set-url origin git@github-personal:LokeshNanda/setup-guides.git
        ```
      * **For Work Projects:**
        ```bash
        cd /path/to/work/project
        git remote set-url origin git@github-work:work-org/repo.git
        git remote set-url origin git@github-work:xyz-group/int-generic.git
        ```

    > **Note:** The format is `git@HOST_NICKNAME:GITHUB_USERNAME/REPOSITORY.git`.

### When Cloning a New Repository:

When you clone a new project, use the custom `HOST_NICKNAME` directly:

  * **Personal Clone:** `git clone git@github-personal:personal-user/new-repo.git`
  * **Work Clone:** `git clone git@github-work:work-org/new-repo.git`
  * **Example:** `git clone git@github-personal:LokeshNanda/setup-guides.git`
  * **Example Work:** `git clone git@github-work:xyz-company/new-repo.git`