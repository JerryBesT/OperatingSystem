set $lastcs = -1

define hook-stop
  # There doesn't seem to be a good way to detect if we're in 16- or
  # 32-bit mode, but in 32-bit mode we always run with CS == 8 in the
  # kernel and CS == 35 in user space
  if $cs == 8 || $cs == 35
    if $lastcs != 8 && $lastcs != 35
      set architecture i386
    end
    x/i $pc
  else
    if $lastcs == -1 || $lastcs == 8 || $lastcs == 35
      set architecture i8086
    end
    # Translate the segment:offset into a physical address
    printf "[%4x:%4x] ", $cs, $eip
    x/i $cs*16+$eip
  end
  set $lastcs = $cs
end

echo Connecting to QEMU\n

echo (gdb) target remote localhost:28922\n
target remote localhost:28922

echo (gdb) symbol-file kernel/kernel\n
symbol-file kernel/kernel

echo (gdb) add-symbol-file kernel/bootblock.o 0x7c00\n
add-symbol-file kernel/bootblock.out 0x7c00

source tools/gdbutil

echo \n
echo Execution is currently paused, type "continue" to start executing.\n
echo Ctrl-C pauses execution again. \n
echo "break" sets breakpoints. \n
echo "step" and "stepi" advance by one line or instruction. \n
echo "next" is like "step" but treats subroutines as single instructions. \n
echo "print" evaluates and prints c expressions. \n
echo Type "help" followed by command name for full documentation, \n
echo or "help" for all commands.\n
echo Online manual: http://sourceware.org/gdb/current/onlinedocs/gdb/\n
