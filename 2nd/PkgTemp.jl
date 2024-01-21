using PkgTemplates
t = Template(;
    user="jake484",
    host="github.com",
    plugins=[
        Git(ssh=false),
        TravisCI(),
        Documenter(),
        GitHubPages(),
        GitHubActions(
            file="2nd\\Documentation.yml"
        )]
)
t("Electrical.jl")