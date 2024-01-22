# 软件包开发

1. 创建软件包
2. 发布至github并初始化相关配置
3. 添加至官方注册表
4. 开发、测试、编写文档

## Gitkraken

[Git图形化界面](https://www.gitkraken.com/)，可免费使用，[Github学生包](https://education.github.com/discount_requests/application)可使用Pro

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

文档主要使用[Documenter.jl](https://documenter.juliadocs.org/stable/)软件包，它可以根据源代码中的注释自动生成文档。使用示例：

给函数编写文档：

```julia
"""
    Analog(name::String, value::Float64)

创建一个模拟量对象。
"""
struct Analog
    name::String
    value::Float64
end


"""
    analog(name::String)

外部构造函数：创建一个模拟量对象，初始值为0。
"""
function analog(name::String)
    Analog(name, 0)
end

"""
    analog()

外部构造函数：创建一个匿名模拟量对象，初始值为0。
"""
function analog()
    return Analog("", 0)
end
```

在`test\runtests.jl`中添加

```julia
using Electrical
using Test

@testset "Analog" begin
    @test analog("A") == Analog("A", 0)
    @test analog() == Analog("", 0)
end
```

在`docs\src\index.md`中添加

```markdown
# Electrical

Documentation for [Electrical](https://github.com/jake484/Electrical.jl).

## 文档内容

```@contents
Pages = ["index.md"]
```

## 索引

```@index
Pages = ["index.md"]
```

## 函数与类型

```@autodocs
Modules = [Electrical]
```
```

在`docs\make.jl`中添加

```julia
pages=[
    "Home" => "index.md",
    "Test" => "test/test.md",
],
```

在`docs\src\test\test.md`中添加

```markdown

# 测试

## 测试1

```@example
using Test
@testset "测试1" begin
    @test 1 == 1
end
```

## 测试2

```@example
sin(1)
```

```


更多内容请参考[Documenter.jl](https://documenter.juliadocs.org/stable/)的文档。