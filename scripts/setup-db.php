<?php
$hostname = getenv("SCALAR_DB_HOSTNAME");
$username = getenv("SCALAR_DB_USERNAME");
$password = getenv("SCALAR_DB_PASSWORD");
$database = getenv("SCALAR_DB_DATABASE");
$port = getenv("SCALAR_DB_PORT") ? getenv("SCALAR_DB_PORT") : 3306;

$stderr = fopen("php://stderr", "w");
$db_script_path = "system/application/config/scalar_store.sql";
$retries = 5;

// test the connection
do {
  $mysql = new mysqli($hostname, $username, $password, $database, $port);
  if ($mysql->connect_error) {
    fwrite($stderr, "\n" . "MySQL Connection Error: (" . $mysql->connect_errno . ") " . $mysql->connect_error . "\n");
    --$retries;
    if ($retries <= 0) {
      exit(1);
    }
    sleep(5);
  }
} while ($mysql->connect_error);

// test that the database exists
$db_create_query = "CREATE DATABASE IF NOT EXISTS `" . $mysql->real_escape_string($database) . "`";

if (!$mysql->query($db_create_query)) {
  fwrite($stderr, "\n" . 'MySQL "CREATE DATABASE" Error: ' . $mysql->error . "\n");
  $mysql->close();
  exit(1);
}

// for some reason, trying to run `$mysql->query(file_get_contents($db_script_path))`
// gives parsing errors, but splitting the file up into individual statements doesn't.
$db_statements = explode("\n\n", trim(file_get_contents($db_script_path)));
foreach($db_statements as $stmt) {
  if (!$mysql->query($stmt)) {
    fwrite($stderr, "\n" . "Could not setup database! :( Error: " . $mysql->error . "\n");
    $mysql->close();
    exit(1);
  }
}

$mysql->close();
