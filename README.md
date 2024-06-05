# How to add a Docker image to your R project to improve reproducibility

I have gotten into the habit of making Docker images for each of my projects, which is helpful if these
projects are large, and span over multiple years.
Long-running projects are a headache for bioinformaticians because software like R has significant
updates each year and we want to keep our machines running the most up to date software with recent
bug fixes, features and new packages. 

Docker images also help in making the research more reproducible for others who are interested in
taking a deeper dive into the research materials.
This helps auditability and could even help in improving research quality through better transparency.

That said, still it is a bit tricky to achieve, so I thought I would write walk through on how I do it
with an R workflow.

## Step 0: install docker on a linux system

On Ubuntu you can use:

`sudo apt install docker.io`

Other OSs will vary.

## Step 1: Write your R Markdown script

You probably have a workflow that you've been working on which works for your current version of R.
Before we incorporate it into a Docker environement, make sure it compiles.

Use the command rmarkdown::render("workflow.Rmd") at the command line to execute it and ensure it
completes without error.

If you don't have an Rmd script, you could try the one called workflow.Rmd in this repo, which uses a
few CRAN and Bioconductor packages to analyse RNA-seq data from [DEE2](dee2.io).

## Step 2: Put the R Markdown script in a GitHub repo

You probably already do this, but just in case.
Create a repo on GitHub with a README, then run `git clone` on your remote machine, then copy the
script to this location, run `git add`, and `git commit` to change the local repo and then push the
changes to GitHub with `git push`.
Confirm on GitHub that the changes have propagated.
If you don't like GitHub you can use another service like GitLab or Codeberg.

## Step 3: Make an account on Dockerhub

Go to the [Dockerhub website](https://hub.docker.com/) and create an account.
Then at the command line use the `docker login` command to establish your identity.
This is an important step for sharing the newly created Docker image to Dockerhub later on.

## Step 4: Make a Dockerfile

So you have a working R Markdown script, and now we want to be able to make a Docker image to host it.
My suggestion is to use [Bioconductor's docker images](https://www.bioconductor.org/help/docker/)
because they have all the prerequisite system libraries installed so that most bioconductor packages
can be installed easily.

Take a look at the example Dockerfile in this repo.
It uses a bioconductor base image (latest stable release), and them installs some additional utility
system tools that I find useful.
Then it installs the necessary CRAN and Bioconductor packages.
Then it does a git clone of the repo so that it has a copy of the workflow script.

## Step 5: Build the image

The `docker build` command uses the Dockerfile to build the image.
Use the -t parameter to specify a name for the image.
Include your Dockerhub username to distinguish this image from others on your system.
The image name should be similar to the name of the GitHub repo, so you can recognise it later.
Here my image is called `docker_for_r_tutorial`.

```
docker build -t mziemann/docker_for_r_tutorial .
```

It will take 10-20 minutes to build depending on your system.

If the build fails, for example due to missing packages, you'll need to make changes to the Dockerfile
and restart the build.
As docker uses caching to save time, this could cause a problem, so you may need to resort to using the
`--no-cache` option to turn off caching.

Run the `docker images` command to check that the image was built correctly.

## Step 6: Run the workflow in the container

Access the bash prompt in the container with the following command:

```
docker run -it mziemann/docker_for_r_tutorial bash
```

You will then be greeted with the following prompt:

```
root@9a338cb709c6:/docker_for_r_tutorial#
```

Run `ls` to show the contents of the project folder.
Then run `git pull` to ensure that the code is up to date.

Run `R` on the command line and then execute the R Marldown script:

```
rmarkdown::render("workflow.Rmd")
```

It should complete just fine, creating the HTML document and any other output files.

On the host machine, run `docker ps` to bring up the existing docker containers. 

```
$ docker ps
CONTAINER ID   IMAGE                            COMMAND   CREATED         STATUS         PORTS      NAMES
9a338cb709c6   mziemann/docker_for_r_tutorial   "bash"    5 minutes ago   Up 5 minutes   8787/tcp   gracious_darwin
```

Notice the container ID which is a hexadecimal string.
We'll need that to retrieve the output files.
In the next command we copy the project file to the host, so that we can inspect the results.

```
docker cp 9a338cb709c6:/docker_for_r_tutorial/ docker_output
```

Use your web browser to inspect the HTML file and check that the script behaves the same in the Docker
container as compared to the host machine.

If you need to make changes, do that on the local host machine, push changes to GitHub and then pull
them inside the container before executing again.
This may need a few cycles of changes to get things working just right.

## Step 7: Write a meaningful README

Now that the workflow is working, it is a good idea to document the project by developing a good README.
It should describe the motivation of the project, the contents and how to reproduce.
Push the changes to GitHub.

## Step 8: Rebuild the image

Now that the workflow is working and the repo is documented, the image needs to be updated to reflect
these changes.
Run docker rmi to delete the image and then rebuild with the "--no-cache" option.

```
docker build -t mziemann/docker_for_r_tutorial . --no-cache
```

## Step 9: Push the image to Dockerhub

An easy way to share your image is to push it to Dockerhub.

```
docker push mziemann/docker_for_r_tutorial 
```

At this point, it is a good idea to test whether the workflow can be executed on a different system.
Refer to the instructions in step 6. If it works - Congratulations, your level of reproducibility is
higher than 90% of other scientists!

## Step 10: Consider long term preservation/sharing of the code and Docker image

GitHub and Dockerhub are great, but there's no guarantee that these free services will exist long into
the future.
Also consider that the Dockerfile will build now, but in 5 years it probably won't, due to changes in
software repository availability.
My recommendation is to deposit them to a dedicated data archive like Zenodo before submission of the
manuscript to a journal.
In GitHub, tag a "release" and then save the repo as a zip archive.
For the Docker image, use the `docker save` command to save the image as a tar archive.
Deposit these to Zenodo and mint a DOI.
This will ensure preservation of the research artefacts for the lifetime of Zenodo, which is ~25 years.
Software heritage is another good option for sharing research code.

## Related resources

Need a more in depth walk-through? See [our protocol](https://www.protocols.io/view/a-recipe-for-extremely-reproducible-enrichment-ana-j8nlkwpdxl5r/v2). 

Prefer video instructions? See our [YouTube video series](https://www.youtube.com/watch?v=00YdxZq5GBI&list=PLAAydBPtqFMXDpLa796q7f7W1HK4t_6Db&ab_channel=MarkZiemann).
