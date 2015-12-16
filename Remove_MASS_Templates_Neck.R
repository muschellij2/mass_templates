rm(list=ls())
library(extrantsr)
library(fslr)
root_dir = "~/Dropbox/MASS_Templates"
template_dir = file.path(root_dir, 
    "WithCerebellum")
template_dir = path.expand(template_dir)
outdir = file.path(root_dir, 
    "WithCerebellum_noneck")

num_templates = 15
template_files = file.path(template_dir, 
    paste0("Template", 1:num_templates, 
        ".nii.gz"))
template_structs = sub("[.]nii", 
    "_str_cbq.nii", 
    template_files)

template_outfiles = basename(template_files)
template_outfiles = file.path(outdir, 
    template_outfiles)


template_struct_outfiles = 
    basename(template_structs)
template_struct_outfiles = file.path(outdir, 
    template_struct_outfiles)

inum = 1

for (inum in seq(num_templates)) {
    
    tfile = template_files[inum]
    sfile = template_structs[inum]

    ofile = template_outfiles[inum]
    sofile = template_struct_outfiles[inum]

    noneck = remove_neck(file = tfile,
        template.file = 
        file.path( fsldir(), 
            "data", "standard", 
            "MNI152_T1_1mm_brain.nii.gz"),
        template.mask = file.path( fsldir(), 
            "data", "standard", 
            "MNI152_T1_1mm_brain_mask.nii.gz"),
        swapdim = FALSE)

    img = readnii(tfile)
    mask = readnii(sfile)

    # class(noneck) = "nifti"
    # noneck@extender[1] = 0
    # noneck@vox_offset = 352
    # class(mask) = "nifti"
    # img@extender =  NULL
    # mask@extender =  NULL

    dd = dropEmptyImageDimensions(
        noneck,
        other.imgs = c(img = list(img),
            mask = list(mask))
    )

    oimg = dd$other.imgs$img
    omask = dd$other.imgs$mask

    writenii(oimg, 
        filename = ofile)
    writenii(omask, 
        filename = sofile)

    rm(list = c("noneck", "dd"))
    print(inum)
}
