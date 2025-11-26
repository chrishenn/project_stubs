def _python_libs_impl(ctx):
    toolchain = ctx.toolchains["@rules_python//python:toolchain_type"]
    info = toolchain.py3_runtime.interpreter_version_info
    link_flag = "-lpython{}.{}".format(info.major, info.minor)

    cc_info = CcInfo(
        linking_context = cc_common.create_linking_context(
            user_link_flags = [link_flag],
        ),
    )
    return [cc_info]

python_libs = rule(
    implementation = _python_libs_impl,
    toolchains = ["@rules_python//python:toolchain_type"],
)
