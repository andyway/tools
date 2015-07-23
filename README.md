# Tools
Tools for easier development and deployment 

1. Put content of ``web`` folder somewhere on your PHP-enabled web server, and make it
   accessible for the outside world. Let's say for now the script lives
   on http://example.com/git/pull.php

3. Put [config.json] and [pull-project.sh] where pull.php can access and execute it. Add propper access rights to the script:  ``chmod +x pull-project.sh``

4. If you want email notification (yes, you want!), enter your email
   address to **email.to**. The emails will also be sent to the email of the Github
   user who pushed to the repository. To help yourself recognizing where these strange commit
   emails are comming from, you should set **email.from** to something meaningful
   like github-push-notification@example.com.

   You can use it for several repositories or branches at the
   same time by adding more entries to the **endpoints** list. For each endpoint
   you need to set **endpoint.repo** to *"username/reponame"*. You
   can configure endpoints for different branches, for instance if you store your
   website in ``staging`` branch or use different branches for
   development/production etc.

   Set **endpoint.run** to the path of your update script, e.g. ``/path/to/update/script.sh <REPO DIRECTORY>  <WEB DIRECTORY>``.

   For clarity, describe what happened after the update script has been
   executed under **endpoint.action**. Usually that's something like *"Your website XY has
   been updated."*. It will be used as subject in notification emails. This is especially
   helpful if you have multiple endpoints.

   The email will also contain the output of your update script and all
   the messages of the pushed commits.

5. On the settings page of your Github repository, go to **Service Hooks** > **WebHook URLs** and
   enter the public url of your ``github.php``, e.g. http://example.com/git/pull.php.


And that's it.
