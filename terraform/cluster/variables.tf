// required
variable type        {}
variable name        {}
variable environment {}

// optional
variable description {
  default = null
}

variable username    {
  default = null
}

variable password    {
  default = null
}

variable instances   {
  default = []
}

variable template    {
  default = null
}

variable cpu_sockets {
  default = null
}

variable cpu_cores   {
  default = null
}

variable memory      {
  default = null
}

variable disk        {
  default = null
}

variable network     {
  default = null
}

variable nameserver  {
  default = null
}

variable tags {
  default = {}
}

variable tailscale_auth_key {
  default = null
}

variable db_name {
  default = null
}

variable db_username {
  default = null
}

variable db_password {
  default = null
}