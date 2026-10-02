{
  runCommand,
  nodejs_24,
}:
runCommand "check-pi-fast-extension" {
  nativeBuildInputs = [nodejs_24];
} ''
  cp ${./fast.ts} fast.ts
  cp ${./fast.test.ts} fast.test.ts
  node --test fast.test.ts
  touch $out
''
