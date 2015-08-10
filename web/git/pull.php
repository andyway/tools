<?php

/*
 * Endpoint for Github Webhook URLs
 *
 * see: https://help.github.com/articles/post-receive-hooks
 *
 */

// script errors will be send to this email:
$error_mail = "ai@alterwin.com";

function run() {
    global $rawInput;

    // read config.json
    $config_filename = '/home/alterwin/files/tools/config.json';
    if (!file_exists($config_filename)) {
        throw new Exception("Can't find ".$config_filename);
    }
    $config = json_decode(file_get_contents($config_filename), true);

    $postBody = $_POST['payload'];
    $payload = json_decode($postBody);

    if (isset($config['email'])) {
        $headers = 'From: '.$config['email']['from']."\r\n";
        $headers .= 'CC: ' . $payload->pusher->email . "\r\n";
        $headers .= "MIME-Version: 1.0\r\n";
        $headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";
    }

    // check if the request comes from github server
    foreach ($config['endpoints'] as $endpoint) {
        // check if the push came from the right repository and branch
        if ($payload->repository->url == 'https://github.com/' . $endpoint['repo']
            && $payload->ref == 'refs/heads/' . $endpoint['branch']) {

            // execute update script, and record its output
            $run_command = $endpoint['run'] . ' ' . $endpoint['run_user'] . ' ' . $endpoint['dist_dir'] . ' ' . $endpoint['web_dir'];
            ob_start();
            passthru($run_command);
            $output = ob_get_contents();

            // prepare and send the notification email
            if (isset($config['email'])) {
                // send mail to someone, and the github user who pushed the commit
                $body = '<p>The Github user <a href="https://github.com/'
                . $payload->pusher->name .'">@' . $payload->pusher->name . '</a>'
                . ' has pushed to ' . $payload->repository->url
                . ' and consequently, ' . $endpoint['action']
                . '.</p>';

                $body .= '<p>Here\'s a brief list of what has been changed:</p>';
                $body .= '<ul>';
                foreach ($payload->commits as $commit) {
                    $body .= '<li>'.$commit->message.'<br />';
                    $body .= '<small style="color:#999">added: <b>'.count($commit->added)
                        .'</b> &nbsp; modified: <b>'.count($commit->modified)
                        .'</b> &nbsp; removed: <b>'.count($commit->removed)
                        .'</b> &nbsp; <a href="' . $commit->url
                        . '">read more</a></small></li>';
                }
                $body .= '</ul>';
                $body .= '<p>What follows is the output of the script:</p><pre>';
                $body .= $output. '</pre>';
                $body .= '<p>Cheers, <br/>Github Webhook Endpoint</p>';

                mail($config['email']['to'], $endpoint['action'], $body, $headers);
            }
            return true;
        }
    }
}

try {
    if (!isset($_POST['payload'])) {
        echo "Works fine.";
    } else {
        header("HTTP/1.1 200 OK");
        run();
    }
} catch ( Exception $e ) {
    $msg = $e->getMessage();
    mail($error_mail, $msg, ''.$e);
}
