<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 *  Custom Logging class to write logs to STDOUT, rather than a static file.
 *  Uses the "log_threshold" configuration (set within application configuration
 *  files or using the SCALAR_LOG_THRESHOLD environment variable) to determine
 *  whether to print the message.
 *
 *  Following CodeIgniter conventions, naming this MY_Log will prioritize it
 *  over the system Log class.
 *
 *  @see scalar/system/libraries/Log.php
 *  @see patches/system/application/config/development/config.php
 *  @see patches/system/application/config/production/config.php
 */

class MY_Log {
  protected $_threshold = 1;
  protected $_date_fmt  = 'Y-m-d H:i:s';
  protected $_enabled = TRUE;
  protected $_levels  = array('ERROR' => '1', 'DEBUG' => '2',  'INFO' => '3', 'ALL' => '4');

  /**
   *  If $config['log_threshold'] is defined and a numeric value, set it as the threshold.
   */
  public function __construct() {
    if (is_numeric($configured_threshold = config_item("log_threshold"))) {
      $this->_threshold = (int) $configured_threshold;
    }
  }

  /**
   * Write Log File
   *
   * Generally this function will be called using the global log_message() function
   *
   * @param string  the error level
   * @param string  the error message
   * @param bool  whether the error is a native PHP error
   * @return  bool
   */
  public function write_log($level = 'error', $msg, $php_error = FALSE)
  {
    $level = strtoupper($level);

    if ($this->_levels[$level] > $this->_threshold) {
      return;
    }

    $level = $level . "" . ($php_error ? " (PHP)" : "");
    $message = $level.' '.(($level == 'INFO') ? ' -' : '-').' '.date($this->_date_fmt). ' --> '.$msg."\n";
    return file_put_contents("php://stdout", $message);
  }
}
