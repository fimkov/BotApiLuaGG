import { bundle } from 'luabundle'
import fs from 'fs'
import path from "path"

const bundledLua = bundle('./api.lua', {
    metadata: false,
    rootModuleName: "botAPILua"
})

const buildPath = path.normalize("build/botApiLua.lua")

fs.writeFile(buildPath, bundledLua, (err : any) => {
    if (err) throw err
    console.log("Successfully build\n")
})