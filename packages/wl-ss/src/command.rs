use std::process::{Command, Stdio};

use crate::Result;

pub(crate) fn run(program: &str, args: &[&str]) -> Result<String> {
    let mut cmd = Command::new(program);
    cmd.args(args);
    output(&mut cmd)
}

pub(crate) fn output(command: &mut Command) -> Result<String> {
    let output = command
        .stderr(Stdio::inherit())
        .output()
        .map_err(|e| format!("failed to run command {:?}\n{}", command, e))?;

    if !output.status.success() {
        return Err(format!("command {:?} failed with {}", command, output.status).into());
    }

    String::from_utf8(output.stdout)
        .map_err(|e| format!("output of command {:?} is not valid utf-8: {}", command, e).into())
}

pub(crate) fn execute(command: &mut Command) -> Result<()> {
    let status = command
        .status()
        .map_err(|e| format!("failed to run command {:?}\n{}", command, e))?;

    if !status.success() {
        return Err(format!("command {:?} failed with {}", command, status).into());
    }

    Ok(())
}
