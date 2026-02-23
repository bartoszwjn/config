#!/usr/bin/env nu

# Send some test notifications with notify-send
def main [] {
    for urgency in [normal low critical] {
        (
            ^notify-send
            --expire-time 0
            --urgency $urgency
            --app-name "Test app"
            "Summary"
            $"Notification content \(($urgency) urgency\)"
        )
    }

    (
        ^notify-send
        --expire-time 0
        --urgency normal
        --app-name "Test app"
        "Now with icons"
        "This one has an icon!!!"
        --icon audio-volume-medium-symbolic
    )
}
