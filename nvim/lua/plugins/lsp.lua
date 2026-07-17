return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "off",
              diagnosticMode = "openFilesOnly",
              reportMissingImports = "none",
              reportMissingModuleSource = "none",
              reportUnknownVariableType = "none",
              reportUnknownMemberType = "none",
              reportUnknownParameterType = "none",
              reportUnknownArgumentType = "none",
              reportMissingParameterType = "none",
              reportMissingTypeArgument = "none",
            },
          },
        },
      },
    },
  },
}
