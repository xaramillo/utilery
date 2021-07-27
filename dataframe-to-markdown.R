# dataframe-to-markdown.R
# @xaramillo
# usage:
#   source("markdown-tools.R")

# Agrega una fila con guión medio para preparar la tabla al formato Markdown
dataframe_to_markdown <- function(x) {
  require(dplyr)
  x = x %>% mutate_if(is.factor, as.character)
  y = x[1,]
  y = "-"
  x = rbind(y,x)
  return(x)
}


# Guarda la tabla en formato Markdown
save_dataframe_as_markdown <- function(x, file) {
  predata = dataframe_to_markdown(x)
  write.table(predata, file = file, quote=F, sep = "|", row.names=F )
  
}
