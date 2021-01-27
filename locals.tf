locals {
    tags = {
        terraform = true
    }
    tag_list = concat(var.tag_list, local.tags)
}