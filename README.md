# usage

## migrate to github

```bash
(cd ~/usr/git; git clone git@github.com:user/repo.git)
(cd ~/usr/git/misc-play; hg2git.yml -e hg=~/usr/mercurial/repo -e git=~/usr/git/repo -D)
(cd ~/usr/mercurial/repo; hg push git)
(cd ~/usr/git/repo; git pull)
```

## migrate to local git

```bash
(cd ~/usr/mercurial; git init --bare repo-git.git; git clone repo-git.git)
(cd ~/usr/git/misc-play; hg2git.yml -e hg=~/usr/mercurial/repo -e git=~/usr/mercurial/repo-git -D)
(cd ~/usr/mercurial/repo; hg push git)
(cd ~/usr/mercurial/repo-git; git pull)
```
