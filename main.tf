data "template_file" "bootstrap" {
  template = "${file("${path.module}/${var.bootstrap_script_path}")}"

  vars {
    HOSTNAME         = "${var.name}"
    PUPPET_SERVER    = "${var.puppet_server}"
    ENVIRONMENT      = "${var.envrionment}"
    PUPPET_CODE_REPO = "${var.puppet_code_repo}"
  }
}

resource "aws_instance" "instance" {
  ami                    = "${lookup(var.aws_ami_map, var.aws_region_os)}"
  count                  = "${var.number_of_instances}"
  subnet_id              = "${var.subnet_id}"
  instance_type          = "${var.type}"
  key_name               = "${var.key_pair_id}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  vpc_security_group_ids = ["${var.security_group_ids}"]
  user_data              = "${data.template_file.bootstrap.rendered}"

  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "true"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route53_record" "route53_record" {
  zone_id = "${var.zone_id}"
  name    = "${var.name}"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.instance.private_ip}"]
}
