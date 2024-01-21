# 软件包开发

1. 创建软件包
2. 发布至github并初始化相关配置
3. 添加至官方注册表
4. 开发、测试、编写文档

## 创建软件包

软件包创建一般使用PkgTemplates.jl包，它提供了一些模板，可以快速创建一个软件包。

```julia
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
```

生成的文件结构如下：

```
Electrical.jl
├── .github
│   └── workflows
│       └── CI.yml
├── .gitignore
├── .travis.yml
├── LICENSE.md
├── Project.toml
├── README.md
├── REQUIRE
├── docs
│   ├── make.jl
│   └── src
│       └── index.md
├── src
│   └── Electrical.jl
└── test
    └── runtests.jl
```

其具体的内涵为：

- .github/workflows/CI.yml：GitHub Actions的配置文件，用于自动化测试、部署
- .gitignore：git的忽略文件
- .travis.yml：Travis CI的配置文件，用于自动化测试
- LICENSE.md：许可证文件
- Project.toml：项目文件
- README.md：README文件
- docs：文档文件夹
- src：源代码文件夹
- test：测试文件夹

## 发布至github并初始化相关配置

1. 在github上创建一个新的仓库，例如Electrical.jl
2. 简单创建源代码文件src/Electrical.jl/Analog/analog.jl，并编写函数
3. 简单编写测试文件test/runtests.jl
4. 修改docs/make.jl文件，使其能够生成文档
5. 添加test.yaml文件，使其能够在GitHub Actions中运行测试
6. 修改github的workflow权限，使其能够部署文档，路径为：Settings->Actions->General->Workflow permissions
7. 将本地的Electrical.jl文件夹上传至github

## 添加至官方注册表

开启Julia注册

使用方法为：在issure中提交一个issue，标题为`register package`，内容为：

```
@JuliaRegistrator register()
```

使用时需要开启相应的服务

## 开发、测试、编写文档

根据软件包的具体功能，编写相应的函数，并编写测试文件。

文档使用示例：


