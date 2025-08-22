import 'package:flutter/material.dart';
import '../services/distance_service.dart';
import '../services/screenshot_service.dart';
import '../services/location_service.dart';

class DistanceInfoWidget extends StatefulWidget {
  final double busLatitude;
  final double busLongitude;
  final String busNumber;
  final String busLocation;

  const DistanceInfoWidget({
    super.key,
    required this.busLatitude,
    required this.busLongitude,
    required this.busNumber,
    required this.busLocation,
  });

  @override
  State<DistanceInfoWidget> createState() => _DistanceInfoWidgetState();
}

class _DistanceInfoWidgetState extends State<DistanceInfoWidget> {
  final GlobalKey _screenshotKey = GlobalKey();
  Map<String, DistanceInfo>? _distanceInfo;
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calculateDistances();
  }

  void _calculateDistances() {
    setState(() {
      _distanceInfo = DistanceService.getComprehensiveDistanceInfo(
        widget.busLatitude,
        widget.busLongitude,
      );
      _lastUpdated = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_distanceInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RepaintBoundary(
      key: _screenshotKey,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildDistanceCards(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final formattedTime = '${_lastUpdated.hour.toString().padLeft(2, '0')}:'
        '${_lastUpdated.minute.toString().padLeft(2, '0')}';
    
    final hasLocation = LocationService.hasPermission;
    final currentLocation = LocationService.currentLocation;

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.straighten, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Distance Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                if (!hasLocation) {
                  final granted = await LocationService.showLocationDialog();
                  if (granted) {
                    _calculateDistances();
                  }
                } else {
                  await LocationService.getCurrentLocation();
                  _calculateDistances();
                }
              },
              icon: const Icon(Icons.refresh),
              tooltip: hasLocation ? 'Refresh location' : 'Enable location',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasLocation ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasLocation ? Icons.location_on : Icons.location_off,
                    size: 16,
                    color: hasLocation ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasLocation ? 'Real Location' : 'Approximate Location',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasLocation ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.update, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Updated $formattedTime',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceCards() {
    final userToBus = _distanceInfo!['userToBus']!;
    final universityToBus = _distanceInfo!['universityToBus']!;
    final userToUniversity = _distanceInfo!['userToUniversity']!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDistanceCard(
                icon: Icons.person,
                iconColor: Colors.green,
                title: 'You',
                subtitle: 'Bus',
                distance: userToBus.distanceKm,
                time: userToBus.estimatedTimeMinutes,
                backgroundColor: Colors.green[50]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDistanceCard(
                icon: Icons.school,
                iconColor: Colors.blue,
                title: 'University',
                subtitle: 'Bus',
                distance: universityToBus.distanceKm,
                time: universityToBus.estimatedTimeMinutes,
                backgroundColor: Colors.blue[50]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDistanceCard(
          icon: Icons.route,
          iconColor: Colors.orange,
          title: 'You',
          subtitle: 'University',
          distance: userToUniversity.distanceKm,
          time: userToUniversity.estimatedTimeMinutes,
          backgroundColor: Colors.orange[50]!,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildDistanceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double distance,
    required int time,
    required Color backgroundColor,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Icon(
                subtitle == 'Bus' ? Icons.directions_bus : Icons.school,
                color: iconColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            DistanceService.formatDistance(distance),
            style: TextStyle(
              fontSize: isWide ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DistanceService.formatTime(time),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _calculateDistances,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _takeScreenshot,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Screenshot'),
          ),
        ),
      ],
    );
  }

  void _takeScreenshot() async {
    try {
      final distances = <String, double>{
        'You to Bus': _distanceInfo!['userToBus']!.distanceKm,
        'University to Bus': _distanceInfo!['universityToBus']!.distanceKm,
        'You to University': _distanceInfo!['userToUniversity']!.distanceKm,
      };

      final screenshot = await ScreenshotService.saveTrackingScreenshot(
        screenshotKey: _screenshotKey,
        busNumber: widget.busNumber,
        location: widget.busLocation,
        distances: distances,
      );

      if (screenshot != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screenshot saved successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Download',
              textColor: Colors.white,
              onPressed: () => ScreenshotService.downloadScreenshot(screenshot),
            ),
          ),
        );

        // Show screenshot options dialog
        _showScreenshotDialog(screenshot);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking screenshot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showScreenshotDialog(ScreenshotInfo screenshot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Captured'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Screenshot has been captured with distance information.'),
            const SizedBox(height: 16),
            Text(
              'Bus: ${screenshot.busNumber}\n'
              'Location: ${screenshot.location}\n'
              'Time: ${DateTime.parse(screenshot.timestamp).toString().substring(0, 19)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScreenshotService.downloadScreenshot(screenshot);
            },
            child: const Text('Download'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScreenshotService.shareTrackingInfo(screenshot);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
