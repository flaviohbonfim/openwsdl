import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../controller/collection_provider.dart';
import '../models/collection_model.dart';
import '../../editor/controller/tab_manager.dart';
import '../../import_export/services/collection_exporter.dart';

class CollectionTreeView extends StatelessWidget {
  const CollectionTreeView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final collections = provider.collections;

    if (collections.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma coleção salva.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _CollectionItem(collection: collection);
      },
    );
  }
}

class _CollectionItem extends StatefulWidget {
  final Collection collection;

  const _CollectionItem({required this.collection});

  @override
  State<_CollectionItem> createState() => _CollectionItemState();
}

class _CollectionItemState extends State<_CollectionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: Icon(
            _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
            size: 16,
          ),
          title: Row(
            children: [
              const Icon(Icons.bookmark, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.collection.name,
                  style:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          trailing: _buildPopupMenu(context),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                ...widget.collection.folders.map((f) => _FolderItem(
                      collectionId: widget.collection.id,
                      folder: f,
                    )),
                ...widget.collection.requests.map((r) => _RequestItem(
                      collectionId: widget.collection.id,
                      request: r,
                    )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'delete') {
          context
              .read<CollectionProvider>()
              .deleteCollection(widget.collection.id);
        } else if (value == 'add_folder') {
          _showAddFolderDialog(context);
        } else if (value == 'export_json') {
          _exportCollection(context, isPostman: false);
        } else if (value == 'export_postman') {
          _exportCollection(context, isPostman: true);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'add_folder',
          child: Text('Nova Pasta', style: TextStyle(fontSize: 12)),
        ),
        const PopupMenuItem(
          value: 'export_json',
          child: Text('Exportar JSON', style: TextStyle(fontSize: 12)),
        ),
        const PopupMenuItem(
          value: 'export_postman',
          child: Text('Exportar Postman', style: TextStyle(fontSize: 12)),
        ),
        const PopupMenuItem(
          value: 'delete',
          child:
              Text('Excluir', style: TextStyle(fontSize: 12, color: Colors.red)),
        ),
      ],
    );
  }

  void _exportCollection(BuildContext context, {required bool isPostman}) async {
    try {
      final content = isPostman
          ? CollectionExporter.exportToPostman(widget.collection)
          : CollectionExporter.exportToJson(widget.collection);

      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) return;

      final fileName =
          '${widget.collection.name}_${isPostman ? 'postman' : 'lite'}.json';
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(content);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exportado para: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Pasta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da Pasta'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context
                    .read<CollectionProvider>()
                    .addFolder(widget.collection.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

class _FolderItem extends StatefulWidget {
  final String collectionId;
  final Folder folder;

  const _FolderItem({required this.collectionId, required this.folder});

  @override
  State<_FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<_FolderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          horizontalTitleGap: 0,
          leading: Icon(
            _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
            size: 16,
          ),
          title: Row(
            children: [
              const Icon(Icons.folder, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.folder.name,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          trailing: _buildPopupMenu(context),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                ...widget.folder.folders.map((f) => _FolderItem(
                      collectionId: widget.collectionId,
                      folder: f,
                    )),
                ...widget.folder.requests.map((r) => _RequestItem(
                      collectionId: widget.collectionId,
                      request: r,
                      folderId: widget.folder.id,
                    )),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 16),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'delete') {
          context
              .read<CollectionProvider>()
              .deleteFolder(widget.collectionId, widget.folder.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child:
              Text('Excluir', style: TextStyle(fontSize: 12, color: Colors.red)),
        ),
      ],
    );
  }
}

class _RequestItem extends StatelessWidget {
  final String collectionId;
  final String? folderId;
  final SavedRequest request;

  const _RequestItem({
    required this.collectionId,
    this.folderId,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 0,
      leading: const SizedBox(width: 16),
      title: Row(
        children: [
          const Icon(Icons.http, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              request.name,
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onTap: () {
        context.read<TabManager>().addSavedRequestTab(
              request,
              collectionId,
              folderId: folderId,
            );
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 16),
        onPressed: () {
          context.read<CollectionProvider>().deleteRequest(
                collectionId,
                request.id,
                folderId: folderId,
              );
        },
      ),
    );
  }
}
