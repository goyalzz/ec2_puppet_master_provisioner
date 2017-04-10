module "ec_puppet_provisioner" {
  source             = "../"
  subnet_id          = "subnet-3bcb854d"
  name               = "puppetmaster.test.com"
  key_pair_id        = "ums-dev-key"
  aws_region_os      = "ap-southeast-1-ubuntu"
  security_group_ids = ["sg-e2ff8a85"]
  type               = "t2.nano"
  zone_id            = "Z1WEN8WKRNQH95"
  puppet_server      = "test"
}
