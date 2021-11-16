<?php
// customizing more settings to be controlled by environment variables
$storage_adapter = getenv("SCALAR_STORAGE_ADAPTER") ? getenv("SCALAR_STORAGE_ADAPTER") : "Scalar_Storage_Adapter_Filesystem";
switch ($storage_adapter) {
  case "Scalar_Storage_Adapter_Filesystem":
  case "filesystem":
    $config["storage_adapter"] = "Scalar_Storage_Adapter_Filesystem";
    break;
  case "Scalar_Storage_Adapter_S3":
  case 's3':
    $config["storage_adapter"] = "Scalar_Storage_Adapter_S3";
    break;
  default:
    echo "unrecognized storage_adapter: $storage_adapter. falling back to Filesystem";
    $config["storage_adapter"] = "Scalar_Storage_Adapter_Filesystem";
}

if ($config["storage_adapter"] == "Scalar_Storage_Adapter_S3") {
  $config["storage_adapter_options"] = array(
    "awsAccessKey" => (getenv("SCALAR_AWS_ACCESS_KEY_ID") ? getenv("SCALAR_AWS_ACCESS_KEY_ID") : ""),
    "awsSecretKey" => (getenv("SCALAR_AWS_SECRET_ACCESS_KEY") ? getenv("SCALAR_AWS_SECRET_ACCESS_KEY") : ""),
    "bucket"       => (getenv("SCALAR_S3_BUCKET") ? getenv("SCALAR_S3_BUCKET") : ""),
    "hostname"     => (getenv("SCALAR_S3_HOSTNAME") ? getenv("SCALAR_S3_HOSTNAME") : ""),
    "forceSSL"     => (bool) (getenv("SCALAR_S3_FORCE_SSL") ? getenv("SCALAR_S3_FORCE_SSL") : ""),
  );
} else {
  $config["storage_adapter_options"] = array(
    "fileMode" => getenv('SCALAR_FILESTORAGE_FILE_MODE') ? intval(getenv('SCALAR_FILESTORAGE_MODE'), 0) : 0664,
    "dirMode" => getenv('SCALAR_FILESTORAGE_DIR_MODE') ? intval(getenv('SCALAR_FILESTORAGE_DIR_MODE'), 0) : 0775,
    "localDir" => "uploads"
  );
}

// prevent a buggy iframe
$config["external_direct_hyperlink"] = getenv("SCALAR_EXTERNAL_DIRECT_HYPERLINK") ? ((bool) getenv("SCALAR_EXTERNAL_DIRECT_HYPERLINK")) : true;

if (getenv("SCALAR_REGISTRATION_KEY")) {
  $config["register_key"] = explode(",", getenv("SCALAR_REGISTRATION_KEY"));
}

// default smtp port to 587, which is used in the fargate stack
$config["smtp_port"] = (getenv("SCALAR_SMTP_PORT") ? getenv("SCALAR_SMTP_PORT") : "587");
$config['smtp_secure'] = (getenv("SCALAR_SMTP_SECURE") ? getenv("SCALAR_SMTP_SECURE") : "tls"); // or "ssl"
