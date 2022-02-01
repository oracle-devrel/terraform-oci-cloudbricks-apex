# Copyright (c) 2021 Oracle and/or its affiliates.
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# ordsconfig.tf
#
# Purpose: Finish ORDS Configuration on static computes


resource "local_file" "WalletFile" {
  content_base64 = oci_database_autonomous_database_wallet.ATP_database_wallet.content
  filename       = var.ATP_tde_wallet_zip_file


}


resource "null_resource" "ORDSConfig" {
  depends_on = [oci_core_instance.Compute, oci_database_autonomous_database.ATPdatabase, oci_core_network_security_group_security_rule.ATPSecurityEgressGroupRule, oci_core_network_security_group_security_rule.ATPSecurityIngressGroupRules]

  count = var.num_instances

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.Compute[count.index].private_ip
      private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
      agent       = false
      timeout     = "2m"
    }
    inline = [
      "sudo yum install ords -y",
      "sudo yum install sqlcl -y",
      "sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp",
      "sudo firewall-cmd --reload",
    ]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.Compute[count.index].private_ip
      private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
      agent       = false
      timeout     = "2m"
    }
    source      = "${path.module}/ords/ords_conf.zip"
    destination = "/home/opc/ords_conf.zip"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.Compute[count.index].private_ip
      private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
      agent       = false
      timeout     = "2m"
    }
    source      = var.ATP_tde_wallet_zip_file
    destination = "/home/opc/${var.ATP_tde_wallet_zip_file}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.Compute[count.index].private_ip
      private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
      agent       = false
      timeout     = "2m"
    }


    inline = [
      "sudo wget https://objectstorage.sa-santiago-1.oraclecloud.com/p/-fuByHbwU299KLAB7XV6ovR-USKL81DedzPEe4kRIoDsZTax8-5WaVNZ3moBWYk3/n/idhkis4m3p5e/b/Shared_Bucket/o/apex_21.2.zip -P /opt/oracle/ords/",
      "sudo chown oracle:oinstall /opt/oracle/ords/apex_21.2.zip",
      "sudo su - oracle -c 'unzip -q /opt/oracle/ords/apex_21.2.zip -d /opt/oracle/ords/'",

    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.Compute[count.index].private_ip
      private_key = var.ssh_private_is_path ? file(var.ssh_private_key) : var.ssh_private_key
      agent       = false
      timeout     = "2m"
    }


    inline = [
      "sudo mv /home/opc/tde_wallet*.zip /home/oracle/wallet.zip",
      "sudo chown oracle:oinstall /home/oracle/wallet.zip",
      "sudo mv /home/opc/ords_conf.zip /opt/oracle/ords/",
      "sudo chown oracle:oinstall /opt/oracle/ords/ords_conf.zip",
      "sudo su - oracle -c 'unzip -q /opt/oracle/ords/ords_conf.zip -d /opt/oracle/ords/'",
      "sudo su - oracle -c 'sed -i 's/PASSWORD_HERE/${var.ATP_password}/g' /opt/oracle/ords/conf/ords/create_user.sql'",      
      "sudo su - oracle -c 'sed -i 's/_NODE_NUMBER/${count.index}/g' /opt/oracle/ords/conf/ords/create_user.sql'",
      "sudo su - oracle -c 'sed -i 's/PASSWORD_HERE/${var.ATP_password}/g' /opt/oracle/ords/conf/ords/conf/apex_pu.xml'",
      "sudo su - oracle -c 'sed -i 's/VERSION_HERE/${var.apex_version}/g' /opt/oracle/ords/conf/ords/fix_ords_index.sql'",
      "sudo su - oracle -c 'sed -i 's/DATABASE_NAME_HERE/${var.ATP_database_db_name}/g' /opt/oracle/ords/conf/ords/conf/apex_pu.xml'",
      "sudo su - oracle -c 'sed -i 's/_NODE_NUMBER/${count.index}/g' /opt/oracle/ords/conf/ords/conf/apex_pu.xml'",
      "sudo su - oracle -c 'java -jar /opt/oracle/ords/ords.war configdir /opt/oracle/ords/conf'",
      "sudo su - oracle -c 'sql -cloudconfig /home/oracle/wallet.zip admin/${var.ATP_password}@${var.ATP_database_db_name}_high @/opt/oracle/ords/conf/ords/create_user.sql'",      
      "sudo sh -c 'echo \"oracle ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers'",
      "sudo su - oracle -c 'sql -cloudconfig /home/oracle/wallet.zip admin/${var.ATP_password}@${var.ATP_database_db_name}_high @/opt/oracle/ords/conf/ords/fix_ords_index.sql'",
      "sudo sh -c 'cp /opt/oracle/ords/conf/ords/lifecycle_scripts/ords.service /etc/systemd/system/ords.service'",
      "sudo sh -c 'chown root:root /etc/systemd/system/ords.service'",
      "sudo systemctl enable ords",
      "sudo systemctl start ords",
    ]
  }
}
