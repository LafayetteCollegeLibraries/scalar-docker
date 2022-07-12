<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

require_once APPPATH . "config/config.php";

if ($threshold_value = getenv("SCALAR_LOG_THRESHOLD")) {
  if (is_string($threshold_value)) {
    switch(strtoupper($threshold_value)) {
      case "ERROR":
        $config["log_threshold"] = 1;
        break;
      case "DEBUG":
        $config["log_threshold"] = 2;
        break;
      case "OFF":
      case "NONE":
        $config["log_threshold"] = 0;
        break;
    }
  } else if (is_numeric($threshold_value)) {
    $config["log_threshold"] = (int) $threshold_value;
  }
}
