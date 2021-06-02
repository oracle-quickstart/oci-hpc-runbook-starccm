# Default IMAGE is set to Oracle Linux 7.5 installation
variable "image_OracleLinux7_6" {
        type = "map"
        default = {
                us-phoenix-1    = "ocid1.image.oc1.phx.aaaaaaaa5b5tbfa4qkmu5fkm2m4aaluaqu73f32peylcjhs3vaglu6e223yq"
                us-ashburn-1    = "ocid1.image.oc1.iad.aaaaaaaay66pu7z27ltbx2uuatzgfywzixbp34wx7xoze52pk33psz47vlfa"
                eu-frankfurt-1  = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaazfzlw2infpo3svzjgrcl237xsbod4l5yuzfpqdqmmawia2womz5q"
                uk-london-1     = "ocid1.image.oc1.uk-london-1.aaaaaaaaahbkgd2yhw7yg6io76mbuwwtuk4monzpsr3r7nuiegttu5q75r6q"
                ca-toronto-1    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaafdgjpavzr7iwzj4avsk7hzov3jwheu6k3sltlarac6mg6bhopkbq"
                ap-tokyo-1      = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaad4gozsm4dexrtoazw7esigotehv5uhbq4plmqrfrz2gxhag6lgja"
                }
}
variable "image_CentOS7" {
        type = "map"
        default = {
                us-ashburn-1    = "ocid1.image.oc1.iad.aaaaaaaa64ahfqwfhk7ft53o2vc4gz2hb7tiugfjxxaafejbin4zjbg3anpq"
                eu-frankfurt-1  = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaap4e7y2fyzyx57bfxg6rs5zbnbepfmvcjkezfnhnb4tjo77hl2cma"
                uk-london-1     = "ocid1.image.oc1.uk-london-1.aaaaaaaaoy6vxajijvdxwr432alpjqfxokuuserhj7qof6vfv53o2vvxahrq"
                ca-toronto-1    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaanyidznndvmpfwv2uybfotbgr7rm6v5rhrecltptx2dxg76d6gdva"
                ap-tokyo-1      = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa7ggytzvqrgjaxgylzpy4u64puuml2yjfhys4m2thznuwygdyxzzq"
                ap-seoul-1      = "ocid1.image.oc1.ap-seoul-1.aaaaaaaayajtmksg4tot2pvrezgmqbbhgul5co5flnfvx6avt23hvcdtnk3a"
        }
}
variable "image_OracleLinux7_6_GPU" {
        type = "map"
        default = {
                us-phoenix-1    = "ocid1.image.oc1.phx.aaaaaaaabygazardhmwmzlxdhocs6r4vxkqkir3ou7lbi5gamj6462pdep2q"
                us-ashburn-1    = "ocid1.image.oc1.iad.aaaaaaaazu5c2nlmbn7m45tlocyiyplxzyt6gmiuwexk6bq5ctk4jvifepea" 
                eu-frankfurt-1  = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaak63d2y754wfp7sfjicfflfcyeochiojhaxtlshphds7cfhfbbora"
                uk-london-1     = "ocid1.image.oc1.uk-london-1.aaaaaaaakqsj2c3exsezarbd27l7ovruiig2ejsvcwyq7fiiofwixdi5nzgq"
                ca-toronto-1    = "ocid1.image.oc1.ca-toronto-1.aaaaaaaajwjoseooftlfs2zkebde65zfyr6b7iszoqufw2rslhgaal3cbwiq"
                ap-tokyo-1      = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa5mcit6bcgiwmp2yfd6aahi7c374dpceqrxy5hztpxtet3osvh6ca"
                ap-seoul-1      = "ocid1.image.oc1.ap-seoul-1.aaaaaaaalk57s7prtnxu5jurrfg2wbpsxd3mekxvntwdqo5exjr5mc35suoq"
                }
}
