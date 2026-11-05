return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local jdtls = require("jdtls")
        local mason_registry = require("mason-registry")

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                local pkg = mason_registry.get_package("jdtls")
                local install_path = pkg:get_install_path()

                local root_dir = vim.fs.dirname(
                    vim.fs.find({ "gradlew", "mvnw", "pom.xml", ".git" }, { upward = true })[1]
                ) or vim.fn.getcwd()
                local workspace = vim.fn.stdpath("data") .. "/jdtls-workspaces/" ..
                    vim.fn.fnamemodify(root_dir, ":p:h:t")

                local java_bin = "java"
                local java_home = os.getenv("JAVA_HOME")
                if java_home then
                    java_bin = java_home .. "/bin/java"
                end

                local launcher = vim.fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
                local os_config = "config_mac"
                if vim.fn.has("linux") == 1 then os_config = "config_linux" end

                local capabilities = vim.tbl_deep_extend(
                    "force",
                    vim.lsp.protocol.make_client_capabilities(),
                    require("cmp_nvim_lsp").default_capabilities()
                )

                jdtls.start_or_attach({
                    cmd = {
                        java_bin,
                        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                        "-Dosgi.bundles.defaultStartLevel=4",
                        "-Declipse.product=org.eclipse.jdt.ls.core.product",
                        "-Dlog.level=ALL", "-Xmx1g",
                        "--add-modules=ALL-SYSTEM",
                        "--add-opens", "java.base/java.util=ALL-UNNAMED",
                        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                        "-jar", launcher,
                        "-configuration", install_path .. "/" .. os_config,
                        "-data", workspace,
                    },
                    root_dir = root_dir,
                    capabilities = capabilities,
                    settings = {
                        java = {
                            format = { enabled = true },
                            saveActions = { organizeImports = true },
                            completion = { importOrder = { "java", "javax", "com", "org" } },
                        },
                    },
                })
            end,
        })
    end,
}
