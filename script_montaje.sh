#Script para realizar desde el punto 1 hasta el 6 del archivo guía de Andrés para la creación de una llamada al sistema
#FAVOR DE MODIFICAR EL CÓDIGO SEGÚN SEA NECESARIO!!!!

# Descarga del kernel y descomprime el mismo...
curl -o ./Kernel_De_Linux.tar.xz "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.138.tar.xz"
tar -xJf Kernel_De_Linux.tar.xz -C ./

#Creación de los archivos necesarios para las syscalls...
mkdir "./linux-5.15.138/$LOGNAME"
touch "./linux-5.15.138/$LOGNAME/$LOGNAME"_syscall.c

#Programa para realizar operaciones según una entrada...
echo "
#include <linux/kernel.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE3(${LOGNAME}syscall, char*, operation, int, num1, int, num2)
{
    long result;
    if (strcmp(operation, "suma") == 0) {
        result = num1 + num2;
    } else if (strcmp(operation, "resta") == 0) {
        result = num1 - num2;
    } else if (strcmp(operation, "multiplicacion") == 0) {
        result = num1 * num2;
    } else if (strcmp(operation, "division") == 0) {
        if (num2 == 0) {
            printk("Division entre 0 no permitida.\n");
            return -EINVAL;
        }
        result = num1 / num2;
    } else {
        return -EINVAL;
    }
    return result;
}
" >> "./linux-5.15.138/$LOGNAME/$LOGNAME"_syscall.c

echo "obj-y := $LOGNAME"_syscall.o > "./linux-5.15.138/$LOGNAME/Makefile"
echo "teresyscall-y := $LOGNAME"_syscall.o >> "./linux-5.15.138/$LOGNAME/Makefile"

sed -i "1162s|$| $LOGNAME/|" linux-5.15.138/Makefile

sed -i "1384i asmlinkage long sys_$LOGNAME(char* operation,int num1, int num2);" ./linux-5.15.138/include/linux/syscalls.h

echo "548 common ${LOGNAME}syscall sys_${LOGNAME}" >> ./linux-5.15.138/arch/x86/entry/syscalls/syscall_64.tbl


## DESCOMENTAR PARA CONSTRUIR DEPENDENCIAS...
# sudo yum install fedpkg
#
# fedpkg clone -a kernel
#
# sudo dnf builddep kernel/kernel.spec

make -C linux-5.15.138 defconfig

proc_number=$(nproc)
make -j"$proc_number" -C linux-5.15.138 
