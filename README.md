Integration work is based heavily on an [earlier guide by Andrew Taylor](https://about.gitlab.com/blog/2019/03/26/connecting-gitlab-and-pantheon-streamline-wordpress-drupal-workflows/) and GitLab documentation.

This integration will give you the following functionality:
- When code is committed to the GitLab `master` branch, GitLab CI will automatically push it to the `master` branch on Pantheon.
- When a Merge Request is opened on GitLab, GitLab CI will automatically create a branch on Pantheon (using the Merge Request ID 
for naming), push the Merge Request code to the new branch, and spin up a new Multidev environment on Pantheon (if one doesn't 
already exist) using the Terminus CLI.

### Preparation

1. Ensure you have Docker running locally.
2. Generate an SSH key that will be used for communication between GitLab CI and Pantheon servers:
    - `ssh-keygen -t rsa -b 2048 -C "gitlab-pantheon"`
    - Use a filename of your choice
    - Do not set a password
3. Create a [Pantheon Machine Token](https://docs.pantheon.io/machine-tokens#create-a-machine-token), save it to a safe, local file for future use. This will be used to allow Terminus within the CI environment to connect with Pantheon infrastructure.
4. While you're working with your account settings in Pantheon, go ahead and add the **Public** SSH key (from an earlier step) to the "SSH Keys" in your Pantheon account.
5. Create a repository on GitLab that will hold your project's source code.

### Setup your codebase

1. Clone the Pantheon repository locally.
2. If present, remove the `.gitlab-ci` directory and `.gitlab-ci.yml` file in the root of the repository.
3. From this repository, copy the `private` directory, `.gitlab-ci.yml` and `Dockerfile` files to the root of the Pantheon repository.

### Build the Docker image

A Docker container will be used during the GitLab CI process in order to interact with Pantheon using the Terminus CLI.

1. Open your terminal, `cd` to the project root (where `Dockerfile` is) and run the following commands
    - `docker login registry.gitlab.com`
    - `docker build -t registry.gitlab.com/[your-account]/[your-repo] .`
    - `docker push registry.gitlab.com/[your-account]/[your-repo]`
2. Verify that your newly created Docker image is showing up on `https://gitlab.com/[your-account]/[your-repo]/container_registry`
    - Click into your newly created image.
    - Copy the URL to the "latest" image tag and save it locally for future use. (There should be an icon next to the tag name which will let you do this.)

### Configure GitLab CI

Go to `https://gitlab.com/[your-account]/[your-repo]/-/settings/ci_cd`, scroll down to the *Variables* section and click *Add Variable*.

1. Create a variable with the *Key* set to "SSH_PRIVATE_KEY".
    - Variable type: File
    - Environments: All (default)
    - Protect variable: Unchecked
    - Mask variable: Unchecked
    - Expand variable reference: Checked
    - Value: The contents of the **Private** SSH key you generated earlier. The Value field **must** end with a new-line character!! See https://docs.gitlab.com/ee/ci/ssh_keys/#troubleshooting.
2. Create a variable with the *Key* set to "PANTHEON_SITE".
    - Variable type: Variable (default)
    - Environments: All (default)
    - Protect variable: Unchecked
    - Mask variable: Unchecked
    - Expand variable reference: Checked
    - Value: The machine name of your pantheon project.
3. Create a variable with the *Key* set to "PANTHEON_GIT_URL".
    - Variable type: Variable (default)
    - Environments: All (default)
    - Protect variable: Unchecked
    - Mask variable: Unchecked
    - Expand variable reference: Checked
    - Value: URL of the Pantheon repository, which will begin with `ssh` and end with `.git`.
4. Create a variable with the *Key* set to "PANTHEON_MACHINE_TOKEN".
    - Variable type: Variable (default)
    - Environments: All (default)
    - Protect variable: Unchecked
    - Mask variable: Unchecked
    - Expand variable reference: Checked
    - Value: The machine token you generated earlier.
5. Create a variable with the *Key* set to "DOCKER_IMAGE_URL".
    - Variable type: Variable (default)
    - Environments: All (default)
    - Protect variable: Unchecked
    - Mask variable: Unchecked
    - Expand variable reference: Checked
    - Value: The URL of the "latest" Docker image you generated earlier.

### Push and test the changes

In the root of your codebase, run:
- `git remote set-url origin git@gitlab.com:[your-account]]/[your-repo].git`
- `git push origin master --force`

That's it! Your integration is complete.

### Tips

1. If your GitLab runner errors out with `gitlab exec /bin/sh: exec format error`, you probably built the Docker image 
on an architecture that doesn't match up the runner's architecture. For example, you may have built the image on `arm64`,
but your runner may be using `amd64`. See the comment in `Dockerfile` for an example solution.



