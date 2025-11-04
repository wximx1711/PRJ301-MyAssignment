            </div>
        </div>
    </main>
    
    <footer class="bg-light mt-5 py-3">
        <div class="container-fluid text-center">
            <small class="text-muted">&copy; 2025 Leave Management System. All rights reserved.</small>
        </div>
    </footer>
    
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
    <!-- Select2 JS -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <!-- FullCalendar JS -->
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/locales/vi.js"></script>
    
    <script>
        // Configure Toastr
        toastr.options = {
            "closeButton": true,
            "debug": false,
            "newestOnTop": true,
            "progressBar": true,
            "positionClass": "toast-top-right",
            "preventDuplicates": false,
            "onclick": null,
            "showDuration": "300",
            "hideDuration": "1000",
            "timeOut": "5000",
            "extendedTimeOut": "1000",
            "showEasing": "swing",
            "hideEasing": "linear",
            "showMethod": "fadeIn",
            "hideMethod": "fadeOut"
        };
        
        // Load notification count
        function loadNotificationCount() {
            $.ajax({
                url: '${pageContext.request.contextPath}/api/notifications?action=count',
                type: 'GET',
                success: function(data) {
                    const count = data.unreadCount || 0;
                    const badge = $('#notificationBadge');
                    if (count > 0) {
                        badge.text(count).removeClass('d-none');
                    } else {
                        badge.addClass('d-none');
                    }
                },
                error: function() {
                    console.error('Failed to load notification count');
                }
            });
        }
        
        // Load notification count on page load
        $(document).ready(function() {
            loadNotificationCount();
            // Refresh notification count every 30 seconds
            setInterval(loadNotificationCount, 30000);
        });
    </script>
</body>
</html>

