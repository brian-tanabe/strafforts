import { HtmlHelpers } from '../helpers/htmlHelpers';
import Overview from '../views/overview';

export namespace EventBinders {

    export function bindAll() {
        const eventBinders = () => {
            // Enable Bootstrap tooltip.
            ($('[data-toggle="tooltip"]') as any).tooltip({
                trigger : 'hover',
            });
            $('[data-toggle="tooltip"]').on('click', (event) => {
                ($(event.currentTarget) as any).tooltip('hide');
            });

            // Disable double clicking for logo and navigation items.
            const selectors = '.main-header .logo, a[id^="best-efforts-for-"], a[id^="races-for-"]';
            $(document).on('dblclick', selectors, (event) => {
                event.preventDefault();
            });

            // Disable clicking for 'PBs by Distance', 'Race by Distance' and 'Race by Year' treeview headers.
            $('.sidebar-menu .disabled').click(false);

            // Load Races Overview upon clicking 'Races' tab button if not yet created.
            $(document).on('click', "a[href^='#pane-races']", () => {
                if ($('#pane-races .loading-icon-panel').length) {
                    new Overview().loadRacesPanel();
                }
            });

            // Bind race filter buttons in Races Timeline view.
            $(document).on('click', '.filter-buttons .btn:not(.show-all)', (event) => {
                // Set the filter button to active upon clicking.
                $('.filter-buttons .btn').removeClass('active');
                $('.filter-buttons .show-all').removeClass('hidden').fadeIn();
                $(event.currentTarget).addClass('active');
            });

            $(document).on('click', '.filter-buttons .btn-race-distance, .timeline-header .btn', (event) => {
                const distance = $(event.currentTarget).attr('data-race-distance');

                // Show all year labels.
                $('.time-label').fadeIn();

                // Show only timeline items of this distance.
                $('.timeline-item').parent().hide();
                $(`.timeline-item[data-race-distance='${distance}']`).parent().fadeIn();
            });

            $(document).on('click', '.timeline-header .btn', (event) => {
                const distance = $(event.currentTarget).attr('data-race-distance');

                // Update the state of filter buttons.
                $('.filter-buttons .btn').removeClass('active');
                $('.filter-buttons .show-all').removeClass('hidden').fadeIn();
                $(`.filter-buttons [data-race-distance='${distance}']`).addClass('active');
            });

            $(document).on('click', '.filter-buttons .btn-race-year', (event) => {
                const year = $(event.currentTarget).attr('data-race-year');

                // Show only time labels, items of this year.
                $('.time-label').hide();
                $(`.time-label[data-race-year='${year}']`).fadeIn();
                $('.timeline-item').parent().hide();
                $(`.timeline-item[data-race-year='${year}']`).parent().fadeIn();
            });

            // Append PR/Contributions welcome badges upon clicking settings toggle button.
            $(document).on('click', '.control-sidebar-toggle', () => {
                if (!$('.link-contributions-welcome').length) {
                    const badges = HtmlHelpers.getContributionWelcomeBadges();
                    $('#control-sidebar-data-tab form').append(badges);
                }
            });

            // Settings' event listeners.
            $(document).on('submit', '.form-save-profile', (event) => {
                saveProfile(event);
            });
            $(document).on('change', '#is_public', (event) => {
                const element = event.currentTarget as HTMLInputElement;
                if (element.checked) {
                    $('#publicize-profile-warning').addClass('hidden');
                } else {
                    $('#publicize-profile-warning').removeClass('hidden');
                }
            });
            $(document).on('submit', '.reset-last-activity-retrieved form', (event) => {
                // Only reset if the button is currently enabled.
                if (!$('.reset-last-activity-retrieved .submit-form').is(':disabled')) {
                    resetLastRetrieveActivity(event);
                }
            });
        };
        return eventBinders;
    }

    function saveProfile(event: JQueryEventObject) {
        event.preventDefault();

        const isPublicCheckbox: HTMLInputElement = $('#is_public')[0] as HTMLInputElement;
        const isPublic = isPublicCheckbox.checked;
        const profileData = {
            is_public: isPublic,
        };

        $.ajax({
            url: $('.form-save-profile').attr('action'),
            data: profileData,
            cache: false,
            type: 'post',
            success: () => {
                toastr.success('Saved Successfully!');
                $('#publicize-profile-warning').addClass('hidden');
            },
            error: (xhr, ajaxOptions, thrownError) => {
                toastr.error(xhr.status + '\n' + thrownError);
            },
        });
    }

    function resetLastRetrieveActivity(event: JQueryEventObject) {
        event.preventDefault();

        $.ajax({
            url: $('.reset-last-activity-retrieved form').attr('action'),
            data: '',
            cache: false,
            type: 'post',
            success: () => {
                $('.last-activity-retrieved').addClass('hidden');
                $('.last-activity-na').removeClass('hidden');
                $('.reset-last-activity-retrieved .submit-form').prop('disabled', true);
                toastr.success(`Resetted Successfully!<br /><br />
                    A full re-synchronization of all your activities has been queued.`);
            },
            error: (xhr, ajaxOptions, thrownError) => {
                toastr.error(xhr.status + '\n' + thrownError);
            },
        });
    }
}
