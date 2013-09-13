#!/bin/bash
# script name : edit.bash
# script args : $1 -- file to be edited
#       $2 -- comments for git
#
# Make certain that you are only editing the development branch.
# Edit the file supplied as an argument to this script.
#
# The script ensures that edits are pushed to the development 
# branch at the origin before checking out staging to merge
# the edits previously made into staging. The script then pushes
# the merge into the staging branch back at the origin.
#
# After pushing the merge to staging at the origin we are ready to
# deploy to Heroku. Consequently the script lets git know about the
# staging Heroku app for the domain and identifies it as "staging-
# heroku". Then the push is made.
#
# Finally we check out the master branch, verify (--as always), and 
# merge the changes made to the staging branch. Of course this assumes
# that we actually bothered to checkout the staging site and viewed
# the new source code to verify changes and successful implementation.
# Then the changes are pushed to the master branch at the origin at
# GitHub, before identifying and then pushing the changes to the "live"
# or "production" instance ("production-heroku) at Heroku.
# 
git checkout development
git branch
sleep 5
vi $1
git add $1
git commit -m "$2"
git push origin development
while true; do
    read -p "shall we push changes to the staging GitHub repository and the staging instance on Heroku?" yn
    case $yn in
        [Yy]* ) echo "proceeding..."; break;;
        [Nn]* ) exit;;
        * ) echo "please answer yes or no.";;
    esac
done
git checkout staging
git branch
sleep 5
git merge development
git push origin staging
cat ~/.netrc | grep heroku || heroku login
cat ~/.netrc | grep heroku || heroku keys:add
heroku git:remote -a www-finalroundmba-com-staging -r staging-heroku
curl http://www-finalroundmba-com-staging.herokuapp.com | more
git push staging-heroku staging:master
while true; do
    read -p "shall we push changes to the master GitHub repository and the production instance on Heroku?" yn
    case $yn in
        [Yy]* ) echo "proceeding..."; break;;
        [Nn]* ) exit;;
        * ) echo "please answer yes or no.";;
    esac
done
git checkout master
git branch
sleep 5
git merge staging
git push origin master
heroku git:remote -a www-finalroundmba-com -r production-heroku
git push production-heroku master:master
curl http://www-finalroundmba-com.herokuapp.com | more
git checkout development
