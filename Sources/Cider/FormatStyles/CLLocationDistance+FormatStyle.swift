//
//  CLLocationDistance+FormatStyle.swift
//
//  Created by Mark Malstrom on 3/5/23.
//

import MapKit

extension MKDistanceFormatter.Units: Codable {}
extension MKDistanceFormatter.DistanceUnitStyle: Codable {}

public extension CLLocationDistance {
    @available(iOS 15.0, *)
    struct FormatStyle: Foundation.FormatStyle {
        private static let formatter = MKDistanceFormatter()

        private var formatterUnits: MKDistanceFormatter.Units = .imperial
        private var formatterUnitStyle: MKDistanceFormatter.DistanceUnitStyle = .abbreviated
        private var formatterLocale: Locale = .current

        public static func units(
            _ value: MKDistanceFormatter.Units,
            style: MKDistanceFormatter.DistanceUnitStyle = .abbreviated
        ) -> Self {
            var instance = Self()
            instance.formatterUnits = value
            instance.formatterUnitStyle = style
            return instance
        }

        public static func locale(_ value: Locale) -> Self {
            var instance = Self()
            instance.formatterLocale = value
            return instance
        }

        public func units(
            _ value: MKDistanceFormatter.Units,
            style: MKDistanceFormatter.DistanceUnitStyle = .abbreviated
        ) -> Self {
            var instance = self
            instance.formatterUnits = value
            instance.formatterUnitStyle = style
            return instance
        }

        public func locale(_ value: Locale) -> Self {
            var instance = self
            instance.formatterLocale = value
            return instance
        }

        public func format(_ value: CLLocationDistance) -> String {
            Self.formatter.units = self.formatterUnits
            Self.formatter.locale = self.formatterLocale
            Self.formatter.unitStyle = self.formatterUnitStyle
            return Self.formatter.string(fromDistance: value)
        }
    }
}

@available(iOS 15.0, *)
public extension CLLocationDistance {
    func formatted<S>(_ format: S) -> S.FormatOutput where Self == S.FormatInput, S: Foundation.FormatStyle {
        return format.format(self)
    }

    func formatted(_ format: CLLocationDistance.FormatStyle) -> CLLocationDistance.FormatStyle.FormatOutput {
        return format.format(self)
    }

    func formatted() -> String {
        self.formatted(CLLocationDistance.FormatStyle())
    }
}
