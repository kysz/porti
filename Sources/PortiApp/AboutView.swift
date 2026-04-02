import AppKit
import SwiftUI

struct AboutView: View {
    private var shortVersion: String {
        AppMetadata.shortVersion
    }

    private var buildVersion: String {
        AppMetadata.buildVersion
    }

    private var iconImage: NSImage {
        AppMetadata.applicationIconImage
    }

    var body: some View {
        HStack {
            Spacer(minLength: 0)

            HStack(alignment: .center, spacing: 20) {
                Image(nsImage: iconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Porti")
                        .font(.system(size: 28, weight: .semibold))

                    Text("Version \(shortVersion) • Build \(buildVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("© Kris Zhou. MIT License.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Link(destination: AppMetadata.repositoryURL) {
                        Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.body)
                    }
                    .buttonStyle(.link)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }
}
