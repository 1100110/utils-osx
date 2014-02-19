#!/usr/bin/env rdmd --compiler=ldmd -g -O -inline -release -noboundscheck 
import std.stdio;
import std.process;
immutable airport = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport";
immutable currentCapacity = "ioreg -w0 -l | grep CurrentCapacity";
immutable designCapacity  = "ioreg -w0 -l | grep DesignCapacity";
void main(string[] args) {
    if(args.length > 1)
        switch(args[1]) {
            case "loadavg":     return execute(["sysctl", "vm.loadavg"]).output[14..28].writeln;
            case "swapusage":   return execute(["sysctl", "vm.swapusage"]).writeln;
            case "status":      return status(args);
            case "ip":          return ip(args);
            case "battery":     return battery();
            default:
                break;
        }
}

void ip(const ref string[] args) {
    if(args.length > 2)
        if(args[2] == "wifi") 
            return execute(["ipconfig", "getifaddr", "en0"]).output.write;
        else if(args[2] == "bluetooth") 
            return execute(["ipconfig", "getifaddr", "en2"]).output.write;
}

void status(const ref string[] args) {
    if(args.length > 2)
        if(args[2] == "wifi")
            return executeShell("ifconfig en0 | grep status:").output[9..$-1].writeln;
        else if(args[2] == "bluetooth")
            return executeShell("ifconfig en2 | grep status:").output[9..$-1].writeln;
}

void battery() {
    import std.conv: to;
    auto current = executeShell(currentCapacity).output[$-5..$-1].to!double;
    auto design  = executeShell(designCapacity).output[$-5..$-1].to!double;
    writef("%s%%", (current / design) * 100);
}
