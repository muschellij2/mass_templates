rm(list=ls())
library(extrantsr)
library(fslr)
root_dir = "~/Dropbox/MASS_Templates"
template_dir = file.path(root_dir, 
    "WithCerebellum_noneck")
template_dir = path.expand(template_dir)
outdir = file.path(root_dir, 
    "WithCerebellum_noneck")

num_templates = 15
template_files = file.path(template_dir, 
    paste0("Template", 1:num_templates, 
        ".nii.gz"))
template_masks = sub("[.]nii", 
    "_str_cbq.nii", 
    template_files)

template_outfiles = nii.stub(template_files)
template_outfiles = paste0(template_outfiles, 
    "_Tissue_Classes.nii.gz")

inum = 1
all.exists = function(x){
    all(file.exists(x))
}

for (inum in seq(num_templates)) {
    
    tfile = template_files[inum]
    sfile = template_masks[inum]

    ofile = template_outfiles[inum]
    prob_ofiles = nii.stub(tfile)
    prob_ofiles = paste0(prob_ofiles, 
        c("_CSF", "_GM", "_WM"),
        ".nii.gz")
    all_ofiles = c(ofile, prob_ofiles)

    if ( !all.exists(all_ofiles) ) {

        img = readnii(tfile)
        mask = readnii(sfile)

        ss = mask_img(img, mask)

        seg = otropos(a = ss,
            x = mask, m = "[0.2,1x1x1]",
            v = 1)

        segmentation = seg$segmentation
        prob_imgs = seg$probabilityimages

        writenii(segmentation, 
            filename = ofile)
        

        mapply(function(img, fname) {
            writenii(img, filename = fname)
            }, prob_imgs, prob_ofiles)

        rm(list = c("seg", "img", 
            "ss", "mask"))
    }
    print(inum)
}
