# List of IP addresses or computer names for your VPS instances
# MAKE SURE TO REPLACE THE EXAMPLE IP ADDRESSES BELOW WITH THE ACTUAL IP ADDRESSES OF YOUR 10 VPS INSTANCES
$vpsList = @(
    "103.253.21.231"# Example: if you only have 1 VPS, keep it like this
    # "IP_Of_VPS_2",  # If you have more VPS, add them here
    # "IP_Of_VPS_3",
    # ... up to 10 VPS
)

# Ask the user what action they want to perform
Write-Host "----------------------------------------------------"
Write-Host "  WINDOWS VPS MANAGEMENT SCRIPT"
Write-Host "----------------------------------------------------"
Write-Host "Enter 'stop' to shut down the VPS instances."
Write-Host "Enter 'start' to start SERVICES on the VPS instances."
Write-Host "Nhập 'reboot' để khởi động lại các VPS (nếu chúng đang chạy)."
Write-Host "Enter 'exit' to quit the script."
Write-Host "----------------------------------------------------"

$action = Read-Host -Prompt "Your choice"

switch ($action.ToLower()) { # Use .ToLower() for case-insensitive input
    "stop" {
        Write-Host "You have chosen to SHUT DOWN the VPS instances." -ForegroundColor Yellow
        foreach ($vps in $vpsList) {
            Write-Host "Sending shutdown command to VPS: ${vps}..." # Sử dụng ${}
            try {
                Invoke-Command -ComputerName ${vps} -ScriptBlock { Stop-Computer -Force -Confirm:$false } -ErrorAction Stop -Authentication Negotiate
                Write-Host "Successfully sent shutdown command to VPS: ${vps}" -ForegroundColor Green
            } catch {
                Write-Host "Error shutting down VPS ${vps}: $($_.Exception.Message)" -ForegroundColor Red # Sử dụng ${} cho $vps
                # break
            }
        }
    }
   "start" { # Logic đã cập nhật cho tùy chọn 'start' để giải thích giới hạn và hướng dẫn người dùng
        Write-Host "Bạn đã chọn BẬT NGUỒN các VPS." -ForegroundColor Yellow
        Write-Host "QUAN TRỌNG: Lệnh Invoke-Command của PowerShell KHÔNG THỂ bật nguồn một máy tính đã tắt hoàn toàn." -ForegroundColor Red
        Write-Host "Điều này là do WinRM (dịch vụ quản lý từ xa) đã tắt khi VPS bị tắt." -ForegroundColor Red
        Write-Host ""
        Write-Host "Để bật nguồn VPS từ trạng thái TẮT HOÀN TOÀN, bạn thường cần một trong các phương pháp sau:" -ForegroundColor Cyan
        Write-Host "1.  Wake-on-LAN (WoL): Nếu đã cấu hình trên VPS và mạng của bạn." -ForegroundColor Cyan
        Write-Host "2.  API/CLI của nền tảng ảo hóa: (ví dụ: Hyper-V, VMware, VirtualBox, Proxmox)." -ForegroundColor Cyan
        Write-Host "3.  Bảng điều khiển/API của nhà cung cấp Cloud: (ví dụ: Azure, AWS, Google Cloud)." -ForegroundColor Cyan
        Write-Host "4.  Truy cập vật lý để nhấn nút nguồn." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Vui lòng sử dụng phương pháp phù hợp dựa trên môi trường lưu trữ VPS của bạn." -ForegroundColor Yellow
        Write-Host "Script này không thể thực hiện hành động bật nguồn trực tiếp cho một VPS đã tắt hoàn toàn." -ForegroundColor Yellow
    }

     "reboot" { # Tùy chọn khởi động lại máy tính (nếu nó đã và đang chạy)
        Write-Host "Bạn đã chọn KHỞI ĐỘNG LẠI các VPS." -ForegroundColor Yellow
        Write-Host "LƯU Ý QUAN TRỌNG: Lệnh này chỉ khởi động lại các máy tính đang chạy." -ForegroundColor Yellow
        Write-Host "Nó KHÔNG THỂ bật nguồn một máy tính đã tắt hoàn toàn. Để làm điều đó, bạn cần Wake-on-LAN hoặc API của nền tảng ảo hóa của bạn." -ForegroundColor Yellow
        Read-Host -Prompt "Nhấn Enter để tiếp tục (khởi động lại máy tính)..." | Out-Null # Dừng lại để người dùng đọc thông báo

        foreach ($vps in $vpsList) {
            Write-Host "Đang gửi lệnh khởi động lại cho VPS: ${vps}..."
            try {
                # Lệnh này sẽ khởi động lại toàn bộ hệ điều hành của VPS
                Invoke-Command -ComputerName ${vps} -ScriptBlock { Restart-Computer -Force -Confirm:$false } -ErrorAction Stop -Authentication Negotiate
                Write-Host "Đã gửi lệnh khởi động lại thành công cho VPS: ${vps}" -ForegroundColor Green
            } catch {
                Write-Host "Lỗi khi khởi động lại VPS ${vps}: $($_.Exception.Message)" -ForegroundColor Red
                # Nếu bạn muốn dừng script ngay khi có lỗi, uncomment dòng dưới:
                # break
            }
        }
    }

    "exit" {
        Write-Host "Exiting script. Goodbye!" -ForegroundColor Yellow
    }
    default {
        Write-Host "Invalid choice. Please enter 'stop', 'start' or 'exit'." -ForegroundColor Red
    }
}

Write-Host "----------------------------------------------------"
