import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../domain/models/task_model.dart';
import '../../../../core/providers/finance_provider.dart';

import '../../../finance/domain/models/category.dart';
import '../../../finance/presentation/screens/manage_categories_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showTaskModal(BuildContext context, {TaskModel? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _TaskModalContent(taskToEdit: taskToEdit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Tareas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hoy'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Completadas'),
            ],
          ),
        ),
        body: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildTaskList(context, provider.tasksForToday),
                _buildTaskList(context, provider.pendingTasks),
                _buildTaskList(context, provider.completedTasks),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTaskModal(context),
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay tareas aquí'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            Provider.of<TaskProvider>(
              context,
              listen: false,
            ).deleteTask(task.id, context);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _showTaskModal(context, taskToEdit: task),
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    final taskProvider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );
                    taskProvider.toggleTaskCompletion(task.id, context);
                  },
                  shape: const CircleBorder(),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TaskModalContent extends StatefulWidget {
  final TaskModel? taskToEdit;

  const _TaskModalContent({this.taskToEdit});

  @override
  State<_TaskModalContent> createState() => _TaskModalContentState();
}

class _TaskModalContentState extends State<_TaskModalContent> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  late DateTime _selectedDate;
  CategoryModel? _selectedCategory;
  late bool _isExpense;
  late bool _linkToFinance;
  bool _isSaving = false;
  String _selectedAttribute = 'Disciplina';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title);
    _descriptionController = TextEditingController(
      text: widget.taskToEdit?.description,
    );
    _costController = TextEditingController(
      text: widget.taskToEdit?.associatedCost?.toStringAsFixed(0),
    );
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now();
    _isExpense = widget.taskToEdit?.isExpense ?? true;
    _linkToFinance =
        (widget.taskToEdit?.associatedCost != null &&
        widget.taskToEdit!.associatedCost! > 0);
    _selectedAttribute = widget.taskToEdit?.attribute ?? 'Disciplina';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategory == null) {
      final financeProvider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      if (widget.taskToEdit?.categoryId != null) {
        _selectedCategory = financeProvider.getCategoryById(
          widget.taskToEdit!.categoryId!,
        );
      }
      if (_selectedCategory == null && financeProvider.categories.isNotEmpty) {
        _selectedCategory = financeProvider.categories.first;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.taskToEdit == null ? 'Nueva Tarea' : 'Editar Tarea',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.sentences,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción (Opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedAttribute,
            decoration: const InputDecoration(
              labelText: 'Atributo RPG',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.stars),
            ),
            items: ['Disciplina', 'Fuerza', 'Intelecto', 'Vitalidad']
                .map((attr) => DropdownMenuItem(value: attr, child: Text(attr)))
                .toList(),
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _selectedAttribute = value);
                    }
                  },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _isSaving
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          SwitchListTile(
            title: const Text('Vincular a Finanzas'),
            subtitle: const Text('¿Implica dinero?'),
            value: _linkToFinance,
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _linkToFinance = value;
                    });
                  },
            contentPadding: EdgeInsets.zero,
          ),
          if (_linkToFinance) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Costo Estimado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CategoryModel>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: financeProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageCategoriesScreen(),
                            ),
                          );
                          setState(() {
                            if (financeProvider.categories.isNotEmpty &&
                                _selectedCategory == null) {
                              _selectedCategory =
                                  financeProvider.categories.first;
                            }
                          });
                        },
                  tooltip: 'Gestionar Categorías',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Tipo: '),
                ChoiceChip(
                  label: const Text('Gasto'),
                  selected: _isExpense,
                  onSelected: _isSaving
                      ? null
                      : (selected) {
                          setState(() => _isExpense = true);
                        },
                  selectedColor: Colors.red.withOpacity(0.2),
                  labelStyle: TextStyle(color: _isExpense ? Colors.red : null),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Ingreso'),
                  selected: !_isExpense,
                  onSelected: _isSaving
                      ? null
                      : (selected) {
                          setState(() => _isExpense = false);
                        },
                  selectedColor: Colors.green.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: !_isExpense ? Colors.green : null,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) {
                      setState(() {
                        _isSaving = true;
                      });

                      // Simulate a small delay to ensure UI updates and prevents double clicks
                      await Future.delayed(const Duration(milliseconds: 300));

                      if (!context.mounted) return;

                      double? cost;
                      if (_linkToFinance) {
                        cost = double.tryParse(_costController.text.trim());
                      }

                      final newTask = TaskModel(
                        id: widget.taskToEdit?.id ?? DateTime.now().toString(),
                        title: title,
                        description: _descriptionController.text.trim(),
                        dueDate: _selectedDate,
                        associatedCost: cost,
                        isExpense: _isExpense,
                        isIncome: !_isExpense,
                        categoryId: _linkToFinance
                            ? _selectedCategory?.id
                            : null,
                        isCompleted: widget.taskToEdit?.isCompleted ?? false,
                        attribute: _selectedAttribute,
                      );

                      if (widget.taskToEdit != null) {
                        taskProvider.updateTask(newTask, context);
                      } else {
                        await taskProvider.addTask(newTask, context);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.taskToEdit == null
                        ? 'Crear Tarea'
                        : 'Guardar Cambios',
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
