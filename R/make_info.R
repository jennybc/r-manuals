#' Make manual from `.texi` file using `makeinfo`
#'
#' @param manual Name of manual, e.g. `R-exts.texi`
#' @param input_dir Input directory
#' @param output_dir Destination directory
#' @inheritParams process_manual
#'
#' @return Runs makeinfo and generates html files
#' @export
make_info <- function(manual, input_dir = "data", output_dir = "temp", verbose = FALSE) {
  if (Sys.which("makeinfo") == "") {
    if (.Platform$OS.type == "windows") {
      try_makeinfo <-
        system2(
          "perl",
          args = c(file.path(dirname(Sys.which("make")), "makeinfo"), "--version"),
          stdout = TRUE,
          stderr = TRUE
        )
      if (!any(grepl("makeinfo", try_makeinfo))) {
        stop("makeinfo not installed.")
      }
    } else{
      stop("makeinfo not installed.")
    }
  }
  fs::dir_create(output_dir)
  fs::dir_ls(path = output_dir) %>% fs::file_delete()
  filename <- glue::glue("{input_dir}/{manual}")
  cli::cli_progress_step("Running makeinfo to convert {.file {filename}} to html")

 if (.Platform$OS.type == "windows") {
   system2(
     "perl",
     args = c(
       file.path(dirname(Sys.which("make")), "makeinfo"),
       glue::glue(
         " --no-headers --no-number-sections --no-node-files --split=chapter --html --output={output_dir} {filename}"
       )
     )
   )
   filename <- sub(".texi", "", manual)
   fs::file_move(glue::glue("{output_dir}/{filename}_0.html"), glue::glue("{output_dir}/index.html"))
 } else {
  system2(
    "makeinfo",
    args = glue::glue(
      " --no-headers --no-number-sections --no-node-files --split=chapter --html --output={output_dir} {filename}"
      )
    )

 }
}


# totod
# In the original makefile they use the option -D UseExternalXrefs
# This seems to define external references to other manuals

